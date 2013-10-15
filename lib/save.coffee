util = require './util'
pokemon = require './pokemon'
items = require './items'

POKEMON_SIZE = 100
POKEMON_SIZE_BOXED = 80
VERSION_RS = 0
VERSION_FRLG = 1
VERSION_E = 2

module.exports.GAME_NAMES = ['Ruby/Sapphire', 'FireRed/LeafGreen', 'Emerald']
module.exports.GAME_SHORTNAMES = ['RS', 'FR/LG', 'E']

module.exports.parse = (save) ->
  {number, trainer, teamAndItems, unknown0, unknown1, rival, pc} = save

  gameCode = trainer.readUInt32LE 0x00AC
  securityKey = 0
  if gameCode > 1
    securityKey = gameCode
    gameCode = 2
  else if gameCode == 1
    securityKey = trainer.readUInt32LE 0x0AF8

  result =
    game:
      code: gameCode
      key: securityKey
    number: number
    trainer:
      name: util.decodeString trainer, 0x0000, 8
      gender: if trainer[0x08] == 0 then 'm' else 'f'
      id: trainer.readUInt16LE 0x000A
      fullId: trainer.readUInt32LE 0x000A
    time:
      hours: trainer.readUInt16LE 0x000E
      minutes: trainer.readUInt8 0x0010
      seconds: trainer.readUInt8 0x0011
      frames: trainer.readUInt8 0x0012
    team: (parseTeam teamAndItems, gameCode, true)
    bag:
      money: securityKey ^ teamAndItems.readUInt32LE (if gameCode == VERSION_FRLG then 0x0290 else 0x0490)
      items: (items.parse teamAndItems, securityKey & 0xFFFF,
        if gameCode == VERSION_FRLG then 0x0310 else 0x0560,
        (switch gameCode
          when VERSION_RS then 20
          when VERSION_FRLG then 42
          when VERSION_E then 30))
      keyItems: (items.parse teamAndItems, securityKey & 0xFFFF,
        (switch gameCode
          when VERSION_RS then 0x5B0
          when VERSION_FRLG then 0x3B8
          when VERSION_E then 0x5D8),
        if gameCode == VERSION_RS then 20 else 30)
      balls: (items.parse teamAndItems, securityKey & 0xFFFF,
        (switch gameCode
          when VERSION_RS then 0x600
          when VERSION_FRLG then 0x430
          when VERSION_E then 0x650),
        if gameCode == VERSION_FRLG then 13 else 16)
      machines: (items.parse teamAndItems, securityKey & 0xFFFF,
        (switch gameCode
          when VERSION_RS then 0x640
          when VERSION_FRLG then 0x464
          when VERSION_E then 0x690),
        if gameCode == VERSION_FRLG then 58 else 64)
      berries: (items.parse teamAndItems, securityKey & 0xFFFF,
        (switch gameCode
          when VERSION_RS then 0x740
          when VERSION_FRLG then 0x54C
          when VERSION_E then 0x790),
        if gameCode == VERSION_FRLG then 43 else 46)

  result.pc = parseBoxes pc, gameCode
  result.pc.items = items.parse teamAndItems, 0,
    if gameCode == VERSION_FRLG then 0x0298 else 0x0498,
    if gameCode == VERSION_FRLG then 30 else 50

  if gameCode == VERSION_FRLG
    result.rival = name: util.decodeString rival, 0x0BCC, 8
   result.buffers =
    trainer: trainer
    teamAndItems: teamAndItems
    unknown0: unknown0
    unknown1: unknown1
    rival: rival
    pc: pc

  result

# Pokémon team parsing
parseTeam = (buffer, gameCode) ->
  offset = if gameCode == 1 then 0x0038 else 0x0238

  for i in [0...buffer.readUInt32LE offset - 4]
    pokemonBuffer = buffer.slice \
      offset + i * POKEMON_SIZE,
      offset + (i+1) * POKEMON_SIZE
    pokemon.parse pokemonBuffer, true

# PC boxes parsing
parseBoxes = do ->
  PC_BOXES = 14
  POKEMON_PER_PC_BOX = 30

  (buffer, gameCode) ->
    offset = if gameCode == VERSION_FRLG then 0x0038 else 0x0238

    currentBox: buffer.readUInt32LE 0x00
    boxes: for box in [0...PC_BOXES]
      boxOffset = 0x04 + box * POKEMON_PER_PC_BOX * POKEMON_SIZE_BOXED
      for i in [0...POKEMON_PER_PC_BOX]
        pokemonBuffer = buffer.slice \
          boxOffset + i * POKEMON_SIZE_BOXED,
          boxOffset + (i+1) * POKEMON_SIZE_BOXED
        pokemon.parse pokemonBuffer
