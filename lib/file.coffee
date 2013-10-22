fs = require 'fs'

spec = require "#{__dirname}/byte-spec"

{UInt8, UInt16LE, UInt32LE, Slice, Skip, ArrayOf, ArrayLiteral, Obj} = spec


# Specs
NUM_SAVES = 2
BLOCKS_PER_SAVE = 14

SIZE_BLOCK_DATA = 4084
SIZE_FILE = 128 * 1024
SIZE_UNKNOWN = 16384
SIZE_SECTIONS = [
  3884, 3968, 3968, 3968, 3848, 3968, 3968,
  3968, 3968, 3968, 3968, 3968, 3968, 2000
]

MAGIC_VALIDATION = 134291493

SPEC_SECTION = Obj [
  {data: Slice SIZE_BLOCK_DATA}
  {section: UInt16LE}
  {checksum: UInt16LE}
  {validation: UInt32LE}
  {saveNum: UInt32LE}
]

SPEC_SAVE = ArrayLiteral (SPEC_SECTION for i in [0...BLOCKS_PER_SAVE])

SPEC_FILE = Obj [
  {saves: ArrayOf NUM_SAVES, SPEC_SAVE}
  {unknown: Slice SIZE_UNKNOWN}
]

checksum = (buffer) ->
  sum = 0
  (sum += buffer.readUInt32LE i) for i in [0...buffer.length] by 4
  sum = ((sum >>> 16) + (sum & 0xFFFF)) & 0xFFFF
  sum

module.exports = (fileBuffer, options) ->
  options ?= {}
  options.thorough ?= false
  options.checks ?= true

  file = SPEC_FILE.read fileBuffer

  if file.bytesRead != SIZE_FILE
    throw Error "Bad file spec size. Expected #{SIZE_FILE}b, got #{file.bytesRead}"

  saves = for save, saveIdx in file.value.saves
    saveNum = null
    sections = []

    # Get array of array of sections (or Error)
    try for block, blockIdx in save
      try
        if sections[block.section]?
          throw Error "repeated section #{block.section}"

        sections[block.section] = block.data.slice 0, SIZE_SECTIONS[block.section]

        if options.checks
          saveNum ?= block.saveNum
          if block.saveNum != saveNum
            throw Error "bad save number: expected #{saveNum}, got #{block.saveNum}"

          if block.validation != MAGIC_VALIDATION
            throw Error "bad validation number: expected #{MAGIC_VALIDATION} got #{block.validation}"

          sum = checksum sections[block.section]
          if block.checksum != sum
            throw Error "bad checksum: expected #{sum}, got #{block.checksum}"

        if options.thorough
          padding = block.data.slice SIZE_SECTIONS[block.section]
          for byte, k in padding when byte != 0x00
            throw Error "non-zero (#{byte}) padding byte at 0x#{(sections[block.section] .length + k).toString 16}"
      catch e then throw Error "#{blockIdx}, #{e.message}"
    catch e then Error "Error in #{saveIdx}:#{e.message}"

    if sections instanceof Error
      sections
    else
      number: saveNum
      trainer: sections[0]
      team_items: sections[1]
      unknown1: sections[2]
      unknown2: sections[3]
      rival: sections[4]
      pc: Buffer.concat sections[5..], SIZE_SECTIONS[5..].reduce (a, b) -> a + b

  saves: saves
  unknown: file.value.unknown

module.exports.SIZE_FILE = SIZE_FILE
