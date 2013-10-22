#!/usr/bin/env coffee

pokedit = require "#{__dirname}/../lib/"
async = require 'async'
express = require 'express'
# coffee = require 'connect-coffee-script'
fs = require 'fs'

PORT = process.env.POKEDIT3_PORT or 1337
PUB = "#{__dirname}/../static"
DEV = process.env.NODE_ENV == 'development'
TMP = "#{process.env.TMP || process.env.TMPDIR || process.env.TEMP || '/tmp' || process.cwd()}/pokedit3saves"



## Utilities ##
padLeft = (n, padding, char = '0') ->
  nStr = n.toString()
  out = ''
  (out += char) for i in [0...(padding - nStr.length)]
  out + nStr



## Express.js setup ##
app = express()
require 'blade'
app.set 'views', "#{__dirname}/../views/"
app.set 'view engine', 'blade'
app.locals {
  JSON: JSON
  pokedit: pokedit
  padLeft: padLeft
}

# Middleware
app.use express.compress()
app.use express.favicon "#{__dirname}/../favicon.ico"
app.use express.logger if DEV then 'dev'
app.use (require 'stylus').middleware {
  src: "#{__dirname}/../style"
  dest: PUB
  compress: not DEV
  firebug: DEV
  linenos: DEV
}
app.use express.bodyParser {
  maxFieldsSize: pokedit.SAVE_SIZE
  maxFields: 3
  uploadDir: TMP
  hash: 'sha1'
}
app.use express.cookieParser process.env.POKEDIT3_COOKIE_KEY ? 'keyboard cat'
app.use express.session {
  cookie:
    maxAge: 365 * 24 * 60 * 60 * 1000
}
app.use (require 'connect-flash')()
app.use express.static PUB
app.use (req, res, next) ->
  res.locals.savegames = req.session.savegames ? []
  next()


## Routes ##
# Savegame uploading
app.post '/upload', (req, res, next) ->
  res.send 400 if not req.files.save?

  if req.files.save.size == 0
    res.status 400
    res.render 'upload', active: 'upload'
    return

  if req.files.save.size != pokedit.file.SIZE_FILE
    res.status 400
    res.render 'upload',
      active: 'upload'
      error: "Bad file size (#{req.files.save.size} bytes, expected #{pokedit.file.SIZE_FILE})."
    return

  fs.readFile req.files.save.path, (err, buffer) ->
    {saves, unknown} = pokedit.file buffer

    if not saves[0]? and not saves[1]?
      res.status 400
      res.render 'upload',
        active: 'upload'
        error: 'Corrupt or invalid save file.'
      return

    num = if not saves[0]?
      req.flash 'warning',
        'Save 0 is broken! Force loading save 1 (##{saves[1].number}).'
      1
    else if not saves[1]?
      req.flash 'warning',
        'Save 1 is broken! Force loading save 0 (##{saves[0].number}).'
      0
    else if saves[0].number >= saves[1].number
      req.flash 'info',
        "Save 0 (##{saves[0].number}) precedes save 1 (##{saves[1].number}). Loaded save 0."
      0
    else
      req.flash 'info',
        "Save 1 (##{saves[1].number}) precedes save 0 (##{saves[0].number}). Loaded save 1."
      1

    save = pokedit.save.parse saves[num]

    saves = null

    async.parallel [
      (c) -> fs.rename req.files.save.path, "#{TMP}/#{req.files.save.hash}.sav", c
      (c) -> fs.writeFile "#{TMP}/#{req.files.save.hash}.json", (JSON.stringify save), c
    ], (err, _) ->
      return next err if err?
      console.log save
      data =
        name: "[#{padLeft (save.common.id & 0xFFFF), 5, '0'}-#{save.number}] #{save.common.name} (#{pokedit.save.GAME_SHORTNAMES[save.common.code]})"
        hash: req.files.save.hash
      if not req.session.savegames?
        req.session.savegames = []
      req.session.savegames.push data
      res.redirect "/save/#{req.files.save.hash}"

# Save visualization
app.get '/save', (req, res) ->
  res.format
    text: ->
      res.send res.locals.savegames
    html: ->
      res.render 'browse', active: 'browse'
    json: ->
      res.send res.locals.savegames

app.get '/save/:hash/download', (req, res, next) ->
  res.download "#{TMP}/#{req.params.hash}.sav", decodeURIComponent req._parsedUrl.query

app.get '/save/:hash', (req, res, next) ->
  fs.readFile "#{TMP}/#{req.params.hash}.json",
    encoding: 'utf-8',
    (err, data) ->
      if err?
        res.status 404
        return next err
      res.format
        text: ->
          res.send data
        html: ->
          res.render 'save',
            save: JSON.parse data
            warnings: req.flash 'warning'
            infos: req.flash 'info'
        json: ->
          res.send data
# Catchall generic route
app.get '/:page?', (req, res) ->
  page = req.params.page ? 'home'
  res.render page, active: page




## Error handling ##
logErrors = (err, req, res, next) ->
  console.error err.stack
  next err

clientErrorHandler = (err, req, res, next) ->
  if res.statusCode == 404 or (err.message.indexOf 'Failed to lookup view "') != -1
    res.status 404
    err = new Error 'File Not Found'
  else if res.statusCode == 200
    res.status 500

  if req.xhr
    res.send 500, error: err
  else
    next err

errorHandlerProd = (err, req, res, next) ->
  if res.StatusCode == 404 or (err.message.indexOf 'Failed to lookup view "') != -1
    res.status 404
    err = new Error 'File Not Found'
  else if res.statusCode == 200
    res.status 500

  delete err.stack
  res.render 'error',
    code: res.statusCode
    error: err
    url: "#{req.protocol}://#{req.headers.host}#{req.path}"
    production: true

errorHandlerDev = (err, req, res, next) ->
  if (err.message.indexOf 'Failed to lookup view "') != -1
    res.status 404
  else if res.statusCode == 200
    res.status 500

  res.render 'error',
    code: res.statusCode
    error: err
    url: "#{req.protocol}://#{req.host}:#{req.port}#{req.path}"
    production: false

app.use logErrors
app.use clientErrorHandler
app.use if DEV then errorHandlerDev else errorHandlerProd



## Application start ##
app.listen(PORT)
console.log "Pokédit3 web interface listening in port #{PORT} (#{if DEV then 'dev' else 'prod'})\n"
