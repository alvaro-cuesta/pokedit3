PokemonString = require "#{__dirname}/String"
Pokemon = require "#{__dirname}/Pokemon"
Items = require "#{__dirname}/Items"
{UInt8, UInt16LE, UInt32LE, Obj, Slice, Wrap, ArrayOf, Transform, Filter, Map} = require "#{__dirname}/byte-spec"

VERSION_RS = 0
VERSION_FRLG = 1
VERSION_E = 2

TEAM_SIZE = 6
NUM_BOXES = 14
POKEMON_PER_BOX = 30

SIZE_EXTENDED_POKEMON = 100

SPEC_TIME = Obj [
  {hours: UInt16LE}
  {minutes: UInt8}
  {seconds: UInt8}
  {frames: UInt8}
]

SPEC_TRAINER_COMMON = Obj [
  {name: PokemonString 8}
  {gender: UInt8}
  {unknown0: UInt8}
  {id: UInt32LE}
  {time: SPEC_TIME}
  {unknown1: Slice 0x99}
  {code: UInt32LE}
]

SPEC_TRAINER_VERSION = [
  Obj [
    {unknown2: Slice()}
  ]
  Obj [
    {unknown2: Slice 0xA48}
    {key: UInt32LE}
    {unknown3: Slice()}
  ]
  Obj [
    {unknown2: Slice()}
  ]
]

SpecTeamItems = (key) ->
  wrap = new Wrap()
  [
    Obj [
      {unknown0: Slice 0x0234}
      {size: wrap.capture UInt32LE}
      {team: wrap.emit (c) -> ArrayOf c[0], Pokemon true}
      {padding: wrap.emit (c) -> Slice SIZE_EXTENDED_POKEMON * (TEAM_SIZE - c.pop())}
      {money: Transform UInt32LE, (v) -> v ^ key}
      {unknown1: UInt32LE}
      {pc: Items 50, key}
      {pocket: Items 20, key}
      {key: Items 20, key}
      {ball: Items 16, key}
      {tmhm: Items 64, key}
      {berry: Items 46, key}
      {unknown2: Slice()}
    ]
    Obj [
      {unknown0: Slice 0x0034}
      {size: wrap.capture UInt32LE}
      {team: wrap.emit (c) -> ArrayOf c[0], Pokemon true}
      {padding: wrap.emit (c) -> Slice SIZE_EXTENDED_POKEMON * (TEAM_SIZE - c.pop())}
      {money: Transform UInt32LE, (v) -> v ^ key}
      {unknown1: UInt32LE}
      {pc: Items 30}
      {pocket: Items 42, key}
      {key: Items 30, key}
      {ball: Items 13, key}
      {tmhm: Items 58, key}
      {berry: Items 43, key}
      {unknown2: Slice()}
    ]
    Obj [
      {unknown0: Slice 0x0234}
      {size: wrap.capture UInt32LE}
      {team: wrap.emit (c) -> ArrayOf c[0], Pokemon true}
      {padding: wrap.emit (c) -> Slice SIZE_EXTENDED_POKEMON * (TEAM_SIZE - c.pop())}
      {money: Transform UInt32LE, (v) -> v ^ key}
      {unknown1: UInt32LE}
      {pc: Items 50, key}
      {pocket: Items 30, key}
      {key: Items 30, key}
      {ball: Items 16, key}
      {tmhm: Items 64, key}
      {berry: Items 46, key}
      {unknown2: Slice()}
    ]
  ]

SPEC_RIVAL = Obj [
  {unknown0: Slice 0x0BCC}
  {name: PokemonString 8}
  {unknown1: Slice()}
]

SPEC_PC = Obj [
  {current: UInt32LE}
  {boxes: ArrayOf NUM_BOXES, Map ((v) -> if v.personality != 0 then v),
    (ArrayOf POKEMON_PER_BOX, Pokemon false)}
  {unknown0: Slice()}
]

module.exports.parse = (save, options) ->
  options ?= {}
  options.checks ?= true
  options.thorough ?= false

  {number, trainer, team_items, rival, pc} = save
  common = SPEC_TRAINER_COMMON.read trainer
  code = Math.min common.value.code, 2

  version = SPEC_TRAINER_VERSION[code].read trainer, common.bytesRead
  key = version.value.key ? common.value.code

  team_items_val = SpecTeamItems(key)[code].read team_items
  rival = SPEC_RIVAL.read rival
  pc = SPEC_PC.read pc

  result =
    number: number
    common: common.value
    version: version.value
    team_items: team_items_val.value
    pc: pc.value
    # game:
    #   code: code
    #   key: key
    # trainer:
    #   name: common.value.name
    #   gender: common.value.gender
    #   id: common.value.id & 0xFFFF
    #   fullId: common.value.id
    # time: common.value.time
    # team: team_items_val.value.team
    # bag:
    #   money: team_items_val.value.money
    #   items: team_items_val.value.pocket
    #   keyItems: team_items_val.value.key
    #   balls: team_items_val.value.ball
    #   machines: team_items_val.value.tmhm
    #   berries: team_items_val.value.berry
    # pc:
    #   currentBox: pc.value.current
    #   boxes: pc.value.boxes
    #   items: team_items_val.value.pc

  if code == VERSION_FRLG
    result.rival = rival.value
    #result.rival = name: rival.value.name

  result

module.exports.GAME_NAMES = ['Ruby/Sapphire', 'FireRed/LeafGreen', 'Emerald']
module.exports.GAME_SHORTNAMES = ['RS', 'FR/LG', 'E']
