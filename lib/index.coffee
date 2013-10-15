module.exports.checksum = checksum = require './checksum'
module.exports.util = require './util'
module.exports.pokemon = require './pokemon'
module.exports.items = require './items'
module.exports.save = require './save'

## File IO ##
fs = require 'fs'

module.exports.readFile = readFile = (path, callback) ->
  fs.readFile path, (err, data) ->
    callback err if err?
    callback (readSave i, data for i in [0...NUM_SAVES]), (readOther data)

## Savegame block reading ##
SAVE_SIZE = 128 * 1024
NUM_SAVES = 2
BLOCKS_PER_SAVE = 14
BLOCK_SIZE = 4096

# Saves
readSave = do ->
  HEADER_SIZE = 12
  SECTION_SIZES = [
    3884, 3968, 3968, 3968, 3848, 3968, 3968,
    3968, 3968, 3968, 3968, 3968, 3968, 2000
  ]

  module.exports.readSave = readSave = (save, buffer) ->
    saveStart = save * BLOCKS_PER_SAVE * BLOCK_SIZE

    try
      for i in [0...BLOCKS_PER_SAVE]
        dataOffset = saveStart + BLOCK_SIZE * i
        headerOffset = dataOffset + BLOCK_SIZE - HEADER_SIZE

        sectionId = buffer.readUInt8 headerOffset + 0
        if not (0 <= sectionId <= 13)
          throw "Invalid section id #{sectionId}"

        padding = buffer.readUInt8 headerOffset + 1
        if padding != 0
          throw "Bad padding value #{padding.toString 16}"

        readChecksum = buffer.readUInt16LE headerOffset + 2
        expectedChecksum = checksum.block buffer,
          dataOffset,
          dataOffset + SECTION_SIZES[sectionId]
        if readChecksum != expectedChecksum
          throw "Bad checksum #{readChecksum.toString 16} (expected #{expectedChecksum.toString 16})"

        validation = buffer.readUInt32LE headerOffset + 4
        if validation != 0x08012025
          throw "Bad validation number #{validation.toString 16}"

        if not saveNum?
          saveNum = buffer.readUInt32LE headerOffset + 8
        else if saveNum != buffer.readUInt32LE headerOffset + 8
          throw "Bad save number #{saveNum}"

        switch sectionId
          when 0
            throw "Repeated trainer section" if trainerBuffer?
            trainerBuffer = new Buffer SECTION_SIZES[sectionId]
            buffer.copy trainerBuffer, 0, dataOffset
          when 1
            throw "Repeated team/items section" if teamAndItemsBuffer?
            teamAndItemsBuffer = new Buffer SECTION_SIZES[sectionId]
            buffer.copy teamAndItemsBuffer, 0, dataOffset
          when 2
            throw "Repeated unknown0 section" if unknown0Buffer?
            unknown0Buffer = new Buffer SECTION_SIZES[sectionId]
            buffer.copy unknown0Buffer, 0, dataOffset
          when 3
            throw "Repeated unknown1 section" if unknown1Buffer?
            unknown1Buffer = new Buffer SECTION_SIZES[sectionId]
            buffer.copy unknown1Buffer, 0, dataOffset
          when 4
            throw "Repeated rival section" if rivalBuffer?
            rivalBuffer = new Buffer SECTION_SIZES[sectionId]
            buffer.copy rivalBuffer, 0, dataOffset
          else
            if not pcBuffer?
              pcBuffer = new Buffer SECTION_SIZES[5..13].reduce (a, b) -> a + b
            buffer.copy pcBuffer,
              SECTION_SIZES[5] * (sectionId - 5),
              dataOffset,
              dataOffset + SECTION_SIZES[sectionId]
    catch e
      console.log "#{e} in block #{i}"
      return

    number: saveNum
    trainer: trainerBuffer
    teamAndItems: teamAndItemsBuffer
    unknown0: unknown0Buffer
    unknown1: unknown1Buffer
    rival: rivalBuffer
    pc: pcBuffer

# "Other" block
readOther = do ->
  OTHER_START = NUM_SAVES * BLOCKS_PER_SAVE * BLOCK_SIZE
  OTHER_SIZE = SAVE_SIZE - OTHER_START

  module.exports.readOther =  (inBuffer) ->
    outBuffer = new Buffer OTHER_SIZE
    inBuffer.copy outBuffer, 0, OTHER_START
    outBuffer
