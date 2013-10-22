#!/usr/bin/env coffee

fs = require 'fs'
pokedit = require "#{__dirname}/../lib/"

fs.readFile "#{__dirname}/../save.sav", (err, buffer) ->
  throw err if err?

  {saves} = pokedit.file buffer

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

  console.log '', (require 'util').inspect save, false, null
