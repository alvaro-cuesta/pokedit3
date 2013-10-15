#!/usr/bin/env coffee

pokedit = require "#{__dirname}/../lib/"
express = require 'express'
blade = require 'blade'
# coffee = require 'connect-coffee-script'

# Express.js setup
PORT = process.env.POKEDIT3_PORT or 1337

SRC = "#{__dirname}/../src"
PUB = "#{__dirname}/../static"

app = express()
dev = app.get('env') == 'development'

app.use express.favicon "#{PUB}/favicon.ico"
app.use express.logger if dev then 'dev'

app.set 'views', SRC
app.set 'view engine', 'blade'

app.use express.logger if dev then 'dev'
app.use (require 'stylus').middleware {
  src: SRC
  dest: PUB
  compress: not dev
  firebug: dev
  linenos: dev
}
app.use express.static PUB

pokedit.readFile "#{__dirname}/../save.sav", (saves, other) ->
  if not saves[0]? and not saves[1]?
    console.log 'Corrupt or invalid save file.'
    return
  else if not saves[0]?
    console.log 'Save 0 is broken. Force loading save 1 (#{saves[1].number}).'
    save = pokedit.save.parse saves[1]
  else if not saves[1]?
    console.log 'Save 1 is broken. Force loading save 0 (#{saves[0].number}).'
    save = pokedit.save.parse saves[0]
  else if saves[0].number >= saves[1].number
    console.log "Save 0 (#{saves[0].number}) > Save 1 (#{saves[1].number}). Loading Save 0."
    save = pokedit.save.parse saves[0]
  else
    console.log "Save 0 (#{saves[0].number}) < Save 1 (#{saves[1].number}). Loading Save 1."
    save = pokedit.save.parse saves[1]

  saves = null

  delete save.buffers

  app.get '/', (req, res) ->
    res.render 'save',
      JSON: JSON
      pokedit: pokedit
      save: save
      pad: (n, padding, char = '0') ->
        nStr = n.toString()
        out = ''
        for i in [0...(padding - nStr.length)]
          out += char
        out + nStr

  app.listen(PORT)
