util = undefined
PokemonString = require "#{__dirname}/String"
Items = require "#{__dirname}/Items"
{UInt8, UInt16LE, UInt32LE, Obj, ArrayOf, Slice, Filter, Wrap, Transform, Pass} = require "#{__dirname}/byte-spec"

checksum = (buffer) ->
  sum = 0
  (sum += buffer.readUInt16LE i) for i in [0...buffer.length] by 2
  sum &= 0xFFFF
  sum

G = growth: Obj [
  {species: UInt16LE}
  {item: UInt16LE}
  {experience: UInt32LE}
  {ppBonus: UInt8} # TODO: BITS!
  {friendship: UInt8}
  {unknown0: UInt16LE}
]

A = moves: Obj [
  {moves: ArrayOf 4, UInt16LE}
  {pp: ArrayOf 4, UInt8}
]

E = evCondition: Obj [
  {hp: UInt8}
  {attack: UInt8}
  {defense: UInt8}
  {speed: UInt8}
  {spAttack: UInt8}
  {spDefense: UInt8}
  {coolness: UInt8}
  {beauty: UInt8}
  {cuteness: UInt8}
  {smartness: UInt8}
  {toughness: UInt8}
  {feel: UInt8}
]

M = misc: Obj [
  {pokerus: UInt8}
  {metLocation: UInt8}
  {origins: UInt16LE} # TODO: BITS!
  {ivs: UInt32LE} # TODO: BITS!
  {ribbons: UInt32LE} # TODO: WHAT?
]

SPEC_POKEMON_DATA = [
  Obj [G, A, E, M]
  Obj [G, A, M, E]
  Obj [G, E, A, M]
  Obj [G, E, M, A]
  Obj [G, M, A, E]
  Obj [G, M, E, A]
  Obj [A, G, E, M]
  Obj [A, G, M, E]
  Obj [A, E, G, M]
  Obj [A, E, M, G]
  Obj [A, M, G, E]
  Obj [A, M, E, G]
  Obj [E, G, A, M]
  Obj [E, G, M, A]
  Obj [E, A, G, M]
  Obj [E, A, M, G]
  Obj [E, M, G, A]
  Obj [E, M, A, G]
  Obj [M, G, A, E]
  Obj [M, G, E, A]
  Obj [M, A, G, E]
  Obj [M, A, E, G]
  Obj [M, E, G, A]
  Obj [M, E, A, G]
]

POKEMON_DATA_LENGTH = 48

SpecPokemon = ->
  wrap = new Wrap()
  [
    {personality: wrap.capture UInt32LE}
    {otId: wrap.capture UInt32LE}
    {nickname: PokemonString 10}
    {language: Transform UInt16LE, (l) -> l - 0x201}
    {otName: PokemonString 7}
    {mark: UInt8} # TODO: BITS!
    {checksum: UInt16LE}
    {unknown0: UInt16LE}
    {data: wrap.emit (c) ->
      [otId, personality] = [c.pop(), c.pop()]
      order = personality % 24
      key = otId ^ personality

      Pass SPEC_POKEMON_DATA[order],
        Transform (Slice POKEMON_DATA_LENGTH), (v) ->
          data = new Buffer POKEMON_DATA_LENGTH
          for i in [0...POKEMON_DATA_LENGTH] by 4
            data.writeInt32LE (key ^ v.readUInt32LE i), i
          data
    }
  ]

SPEC_EXTENDED = [
  {status: UInt32LE} # TODO: BITS!
  {level: UInt8}
  {pokerus: UInt8}
  {hp: UInt16LE}
  {maxHp: UInt16LE}
  {attack: UInt16LE}
  {defense: UInt16LE}
  {speed: UInt16LE}
  {spAttack: UInt16LE}
  {spDefense: UInt16LE}
]

module.exports = (extended) ->
  Obj if extended
      SpecPokemon().concat SPEC_EXTENDED
    else
      SpecPokemon()

module.exports.parseOLD = (buffer, extended) ->
  readChecksum = buffer.readUInt16LE 0x1C
  trainerId = buffer.readUInt32LE 0x04
  personality = buffer.readUInt32LE 0x00

  dataBuffer = new Buffer POKEMON_DATA_SIZE
  for i in [0...POKEMON_DATA_SIZE] by 4
    dataBuffer.writeInt32LE (trainerId ^ personality ^ buffer.readUInt32LE i + 0x20), i

  expectedChecksum = checksum.pokemon dataBuffer

  return if readChecksum == 0 and trainerId == 0 and personality == 0 and expectedChecksum == 0

  if readChecksum != expectedChecksum
    throw "Bad checksum #{readChecksum.toString 16} (expected #{expectedChecksum.toString 16})"

  marks = buffer.readUInt8 0x1B
  language = (buffer.readUInt16LE 0x12) - 0x0201
  data = parseData dataBuffer, personality

  result =
    name: util.decodeString buffer, 0x08, 10
    trainer:
      id: buffer.readUInt16LE 0x04
      fullId: trainerId
      name: util.decodeString buffer, 0x14, 8
      language: language
    personality:
      raw: personality
    data: data
    marks:
      circle: !!(marks & 1)
      square: !!(marks & 2)
      triangle: !!(marks & 4)
      heart: !!(marks & 8)

  # Extended stats (Pokémon is not in box)
  if extended
    result.level = buffer.readUInt8 0x54

    status = buffer.readUInt32LE 0x50
    result.status =
      sleep: (status & 0b111) or false
      poison: !!(status & 8)
      burn: !!(status & 16)
      freeze: !!(status & 32)
      paralysis: !!(status & 64)
      badPoison: !!(status & 128)
    result.remainingPokerus = buffer.readUInt8 0x55
    result.stats =
      hp: buffer.readUInt16LE 0x56
      hpMax: buffer.readUInt16LE 0x58
      attack: buffer.readUInt16LE 0x5A
      defense: buffer.readUInt16LE 0x5C
      speed: buffer.readUInt16LE 0x5E
      spAttack: buffer.readUInt16LE 0x60
      spDefense: buffer.readUInt16LE 0x62

  result



parseData = (buffer, personality, pokemonRSE) ->
  dataOrder = POKEMON_DATA_ORDER[personality % 24]

  species = buffer.readUInt16LE 0 + SUBSTRUCTURE_LENGTH * dataOrder[G]
  item = buffer.readUInt16LE 2 + SUBSTRUCTURE_LENGTH * dataOrder[G]
  bonuses = buffer.readUInt8 8 + SUBSTRUCTURE_LENGTH * dataOrder[G]
  pokerus = buffer.readUInt8 8 + SUBSTRUCTURE_LENGTH * dataOrder[M]

  result =
    growth:
      species:
        id: species
        name: SPECIES[species]
      item:
        id: item
        name: items.NAMES[item]
      experience: buffer.readUInt32LE 4 + SUBSTRUCTURE_LENGTH * dataOrder[G]
      friendship: buffer.readUInt8 9 + SUBSTRUCTURE_LENGTH * dataOrder[G]
    moves: for i in [0..3]
      id = buffer.readUInt16LE 0 + i * 2 + SUBSTRUCTURE_LENGTH * dataOrder[A]
      id: id
      name: MOVES[id]
      pp: buffer.readUInt8 8 + i + SUBSTRUCTURE_LENGTH * dataOrder[A]
      bonus: (bonuses & (0b11 << (i * 2))) >>> (i * 2)
    ev:
      hp: buffer.readUInt8 0 + SUBSTRUCTURE_LENGTH * dataOrder[E]
      attack: buffer.readUInt8 1 + SUBSTRUCTURE_LENGTH * dataOrder[E]
      defense: buffer.readUInt8 2 + SUBSTRUCTURE_LENGTH * dataOrder[E]
      speed: buffer.readUInt8 3 + SUBSTRUCTURE_LENGTH * dataOrder[E]
      spAttack: buffer.readUInt8 4 + SUBSTRUCTURE_LENGTH * dataOrder[E]
      spDefense: buffer.readUInt8 5 + SUBSTRUCTURE_LENGTH * dataOrder[E]
    condition:
      coolness: buffer.readUInt8 6 + SUBSTRUCTURE_LENGTH * dataOrder[E]
      beauty: buffer.readUInt8 7 + SUBSTRUCTURE_LENGTH * dataOrder[E]
      cuteness: buffer.readUInt8 8 + SUBSTRUCTURE_LENGTH * dataOrder[E]
      smartness: buffer.readUInt8 9 + SUBSTRUCTURE_LENGTH * dataOrder[E]
      toughness: buffer.readUInt8 10 + SUBSTRUCTURE_LENGTH * dataOrder[E]
      feel: buffer.readUInt8 11 + SUBSTRUCTURE_LENGTH * dataOrder[E]
    pokerus:
      remaining: pokerus & 0xF
      immune: (pokerus >>> 4) > 0
    met: 0
    origin: 0
    iv: 0
    ribbons: 0

module.exports.LANGUAGES = ['JP', 'EN', 'FR', 'IT', 'DE', undefined, 'ES']

module.exports.SPECIES = [
  undefined
  'Bulbasaur'
  'Ivysaur'
  'Venusaur'
  'Charmander'
  'Charmeleon'
  'Charizard'
  'Squirtle'
  'Wartortle'
  'Blastoise'
  'Caterpie'
  'Metapod'
  'Butterfree'
  'Weedle'
  'Kakuna'
  'Beedrill'
  'Pidgey'
  'Pidgeotto'
  'Pidgeot'
  'Rattata'
  'Raticate'
  'Spearow'
  'Fearow'
  'Ekans'
  'Arbok'
  'Pikachu'
  'Raichu'
  'Sandshrew'
  'Sandslash'
  'Nidoran?'
  'Nidorina'
  'Nidoqueen'
  'Nidoran?'
  'Nidorino'
  'Nidoking'
  'Clefairy'
  'Clefable'
  'Vulpix'
  'Ninetales'
  'Jigglypuff'
  'Wigglytuff'
  'Zubat'
  'Golbat'
  'Oddish'
  'Gloom'
  'Vileplume'
  'Paras'
  'Parasect'
  'Venonat'
  'Venomoth'
  'Diglett'
  'Dugtrio'
  'Meowth'
  'Persian'
  'Psyduck'
  'Golduck'
  'Mankey'
  'Primeape'
  'Growlithe'
  'Arcanine'
  'Poliwag'
  'Poliwhirl'
  'Poliwrath'
  'Abra'
  'Kadabra'
  'Alakazam'
  'Machop'
  'Machoke'
  'Machamp'
  'Bellsprout'
  'Weepinbell'
  'Victreebel'
  'Tentacool'
  'Tentacruel'
  'Geodude'
  'Graveler'
  'Golem'
  'Ponyta'
  'Rapidash'
  'Slowpoke'
  'Slowbro'
  'Magnemite'
  'Magneton'
  'Farfetch\'d'
  'Doduo'
  'Dodrio'
  'Seel'
  'Dewgong'
  'Grimer'
  'Muk'
  'Shellder'
  'Cloyster'
  'Gastly'
  'Haunter'
  'Gengar'
  'Onix'
  'Drowzee'
  'Hypno'
  'Krabby'
  'Kingler'
  'Voltorb'
  'Electrode'
  'Exeggcute'
  'Exeggutor'
  'Cubone'
  'Marowak'
  'Hitmonlee'
  'Hitmonchan'
  'Lickitung'
  'Koffing'
  'Weezing'
  'Rhyhorn'
  'Rhydon'
  'Chansey'
  'Tangela'
  'Kangaskhan'
  'Horsea'
  'Seadra'
  'Goldeen'
  'Seaking'
  'Staryu'
  'Starmie'
  'Mr. Mime'
  'Scyther'
  'Jynx'
  'Electabuzz'
  'Magmar'
  'Pinsir'
  'Tauros'
  'Magikarp'
  'Gyarados'
  'Lapras'
  'Ditto'
  'Eevee'
  'Vaporeon'
  'Jolteon'
  'Flareon'
  'Porygon'
  'Omanyte'
  'Omastar'
  'Kabuto'
  'Kabutops'
  'Aerodactyl'
  'Snorlax'
  'Articuno'
  'Zapdos'
  'Moltres'
  'Dratini'
  'Dragonair'
  'Dragonite'
  'Mewtwo'
  'Mew'
  'Chikorita'
  'Bayleef'
  'Meganium'
  'Cyndaquil'
  'Quilava'
  'Typhlosion'
  'Totodile'
  'Croconaw'
  'Feraligatr'
  'Sentret'
  'Furret'
  'Hoothoot'
  'Noctowl'
  'Ledyba'
  'Ledian'
  'Spinarak'
  'Ariados'
  'Crobat'
  'Chinchou'
  'Lanturn'
  'Pichu'
  'Cleffa'
  'Igglybuff'
  'Togepi'
  'Togetic'
  'Natu'
  'Xatu'
  'Mareep'
  'Flaaffy'
  'Ampharos'
  'Bellossom'
  'Marill'
  'Azumarill'
  'Sudowoodo'
  'Politoed'
  'Hoppip'
  'Skiploom'
  'Jumpluff'
  'Aipom'
  'Sunkern'
  'Sunflora'
  'Yanma'
  'Wooper'
  'Quagsire'
  'Espeon'
  'Umbreon'
  'Murkrow'
  'Slowking'
  'Misdreavus'
  'Unown'
  'Wobbuffet'
  'Girafarig'
  'Pineco'
  'Forretress'
  'Dunsparce'
  'Gligar'
  'Steelix'
  'Snubbull'
  'Granbull'
  'Qwilfish'
  'Scizor'
  'Shuckle'
  'Heracross'
  'Sneasel'
  'Teddiursa'
  'Ursaring'
  'Slugma'
  'Magcargo'
  'Swinub'
  'Piloswine'
  'Corsola'
  'Remoraid'
  'Octillery'
  'Delibird'
  'Mantine'
  'Skarmory'
  'Houndour'
  'Houndoom'
  'Kingdra'
  'Phanpy'
  'Donphan'
  'Porygon2'
  'Stantler'
  'Smeargle'
  'Tyrogue'
  'Hitmontop'
  'Smoochum'
  'Elekid'
  'Magby'
  'Miltank'
  'Blissey'
  'Raikou'
  'Entei'
  'Suicune'
  'Larvitar'
  'Pupitar'
  'Tyranitar'
  'Lugia'
  'Ho-Oh'
  'Celebi'
  '? (glitch Pokémon)'
  '? (glitch Pokémon)'
  '? (glitch Pokémon)'
  '? (glitch Pokémon)'
  '? (glitch Pokémon)'
  '? (glitch Pokémon)'
  '? (glitch Pokémon)'
  '? (glitch Pokémon)'
  '? (glitch Pokémon)'
  '? (glitch Pokémon)'
  '? (glitch Pokémon)'
  '? (glitch Pokémon)'
  '? (glitch Pokémon)'
  '? (glitch Pokémon)'
  '? (glitch Pokémon)'
  '? (glitch Pokémon)'
  '? (glitch Pokémon)'
  '? (glitch Pokémon)'
  '? (glitch Pokémon)'
  '? (glitch Pokémon)'
  '? (glitch Pokémon)'
  '? (glitch Pokémon)'
  '? (glitch Pokémon)'
  '? (glitch Pokémon)'
  '? (glitch Pokémon)'
  'Treecko'
  'Grovyle'
  'Sceptile'
  'Torchic'
  'Combusken'
  'Blaziken'
  'Mudkip'
  'Marshtomp'
  'Swampert'
  'Poochyena'
  'Mightyena'
  'Zigzagoon'
  'Linoone'
  'Wurmple'
  'Silcoon'
  'Beautifly'
  'Cascoon'
  'Dustox'
  'Lotad'
  'Lombre'
  'Ludicolo'
  'Seedot'
  'Nuzleaf'
  'Shiftry'
  'Nincada'
  'Ninjask'
  'Shedinja'
  'Taillow'
  'Swellow'
  'Shroomish'
  'Breloom'
  'Spinda'
  'Wingull'
  'Pelipper'
  'Surskit'
  'Masquerain'
  'Wailmer'
  'Wailord'
  'Skitty'
  'Delcatty'
  'Kecleon'
  'Baltoy'
  'Claydol'
  'Nosepass'
  'Torkoal'
  'Sableye'
  'Barboach'
  'Whiscash'
  'Luvdisc'
  'Corphish'
  'Crawdaunt'
  'Feebas'
  'Milotic'
  'Carvanha'
  'Sharpedo'
  'Trapinch'
  'Vibrava'
  'Flygon'
  'Makuhita'
  'Hariyama'
  'Electrike'
  'Manectric'
  'Numel'
  'Camerupt'
  'Spheal'
  'Sealeo'
  'Walrein'
  'Cacnea'
  'Cacturne'
  'Snorunt'
  'Glalie'
  'Lunatone'
  'Solrock'
  'Azurill'
  'Spoink'
  'Grumpig'
  'Plusle'
  'Minun'
  'Mawile'
  'Meditite'
  'Medicham'
  'Swablu'
  'Altaria'
  'Wynaut'
  'Duskull'
  'Dusclops'
  'Roselia'
  'Slakoth'
  'Vigoroth'
  'Slaking'
  'Gulpin'
  'Swalot'
  'Tropius'
  'Whismur'
  'Loudred'
  'Exploud'
  'Clamperl'
  'Huntail'
  'Gorebyss'
  'Absol'
  'Shuppet'
  'Banette'
  'Seviper'
  'Zangoose'
  'Relicanth'
  'Aron'
  'Lairon'
  'Aggron'
  'Castform'
  'Volbeat'
  'Illumise'
  'Lileep'
  'Cradily'
  'Anorith'
  'Armaldo'
  'Ralts'
  'Kirlia'
  'Gardevoir'
  'Bagon'
  'Shelgon'
  'Salamence'
  'Beldum'
  'Metang'
  'Metagross'
  'Regirock'
  'Regice'
  'Registeel'
  'Kyogre'
  'Groudon'
  'Rayquaza'
  'Latias'
  'Latios'
  'Jirachi'
  'Deoxys'
  'Chimecho'
  'Pokémon Egg'
  'Unown'
  'Unown'
  'Unown'
  'Unown'
  'Unown'
  'Unown'
  'Unown'
  'Unown'
  'Unown'
  'Unown'
  'Unown'
  'Unown'
  'Unown'
  'Unown'
  'Unown'
  'Unown'
  'Unown'
  'Unown'
  'Unown'
  'Unown'
  'Unown'
  'Unown'
  'Unown'
  'Unown'
  'Unown'
  'Unown'
  'Unown'
]

module.exports.MOVES = [
  undefined
  'Pound'
  'Karate Chop'
  'DoubleSlap'
  'Comet Punch'
  'Mega Punch'
  'Pay Day'
  'Fire Punch'
  'Ice Punch'
  'ThunderPunch'
  'Scratch'
  'ViceGrip'
  'Guillotine'
  'Razor Wind'
  'Swords Dance'
  'Cut'
  'Gust'
  'Wing Attack'
  'Whirlwind'
  'Fly'
  'Bind'
  'Slam'
  'Vine Whip'
  'Stomp'
  'Double Kick'
  'Mega Kick'
  'Jump Kick'
  'Rolling Kick'
  'Sand-Attack'
  'Headbutt'
  'Horn Attack'
  'Fury Attack'
  'Horn Drill'
  'Tackle'
  'Body Slam'
  'Wrap'
  'Take Down'
  'Thrash'
  'Double-Edge'
  'Tail Whip'
  'Poison Sting'
  'Twineedle'
  'Pin Missile'
  'Leer'
  'Bite'
  'Growl'
  'Roar'
  'Sing'
  'Supersonic'
  'SonicBoom'
  'Disable'
  'Acid'
  'Ember'
  'Flamethrower'
  'Mist'
  'Water Gun'
  'Hydro Pump'
  'Surf'
  'Ice Beam'
  'Blizzard'
  'Psybeam'
  'BubbleBeam'
  'Aurora Beam'
  'Hyper Beam'
  'Peck'
  'Drill Peck'
  'Submission'
  'Low Kick'
  'Counter'
  'Seismic Toss'
  'Strength'
  'Absorb'
  'Mega Drain'
  'Leech Seed'
  'Growth'
  'Razor Leaf'
  'SolarBeam'
  'PoisonPowder'
  'Stun Spore'
  'Sleep Powder'
  'Petal Dance'
  'String Shot'
  'Dragon Rage'
  'Fire Spin'
  'ThunderShock'
  'Thunderbolt'
  'Thunder Wave'
  'Thunder'
  'Rock Throw'
  'Earthquake'
  'Fissure'
  'Dig'
  'Toxic'
  'Confusion'
  'Psychic'
  'Hypnosis'
  'Meditate'
  'Agility'
  'Quick Attack'
  'Rage'
  'Teleport'
  'Night Shade'
  'Mimic'
  'Screech'
  'Double Team'
  'Recover'
  'Harden'
  'Minimize'
  'SmokeScreen'
  'Confuse Ray'
  'Withdraw'
  'Defense Curl'
  'Barrier'
  'Light Screen'
  'Haze'
  'Reflect'
  'Focus Energy'
  'Bide'
  'Metronome'
  'Mirror Move'
  'Selfdestruct'
  'Egg Bomb'
  'Lick'
  'Smog'
  'Sludge'
  'Bone Club'
  'Fire Blast'
  'Waterfall'
  'Clamp'
  'Swift'
  'Skull Bash'
  'Spike Cannon'
  'Constrict'
  'Amnesia'
  'Kinesis'
  'Softboiled'
  'Hi Jump Kick'
  'Glare'
  'Dream Eater'
  'Poison Gas'
  'Barrage'
  'Leech Life'
  'Lovely Kiss'
  'Sky Attack'
  'Transform'
  'Bubble'
  'Dizzy Punch'
  'Spore'
  'Flash'
  'Psywave'
  'Splash'
  'Acid Armor'
  'Crabhammer'
  'Explosion'
  'Fury Swipes'
  'Bonemerang'
  'Rest'
  'Rock Slide'
  'Hyper Fang'
  'Sharpen'
  'Conversion'
  'Tri Attack'
  'Super Fang'
  'Slash'
  'Substitute'
  'Struggle'
  'Sketch'
  'Triple Kick'
  'Thief'
  'Spider Web'
  'Mind Reader'
  'Nightmare'
  'Flame Wheel'
  'Snore'
  'Curse'
  'Flail'
  'Conversion 2'
  'Aeroblast'
  'Cotton Spore'
  'Reversal'
  'Spite'
  'Powder Snow'
  'Protect'
  'Mach Punch'
  'Scary Face'
  'Faint Attack'
  'Sweet Kiss'
  'Belly Drum'
  'Sludge Bomb'
  'Mud-Slap'
  'Octazooka'
  'Spikes'
  'Zap Cannon'
  'Foresight'
  'Destiny Bond'
  'Perish Song'
  'Icy Wind'
  'Detect'
  'Bone Rush'
  'Lock-On'
  'Outrage'
  'Sandstorm'
  'Giga Drain'
  'Endure'
  'Charm'
  'Rollout'
  'False Swipe'
  'Swagger'
  'Milk Drink'
  'Spark'
  'Fury Cutter'
  'Steel Wing'
  'Mean Look'
  'Attract'
  'Sleep Talk'
  'Heal Bell'
  'Return'
  'Present'
  'Frustration'
  'Safeguard'
  'Pain Split'
  'Sacred Fire'
  'Magnitude'
  'DynamicPunch'
  'Megahorn'
  'DragonBreath'
  'Baton Pass'
  'Encore'
  'Pursuit'
  'Rapid Spin'
  'Sweet Scent'
  'Iron Tail'
  'Metal Claw'
  'Vital Throw'
  'Morning Sun'
  'Synthesis'
  'Moonlight'
  'Hidden Power'
  'Cross Chop'
  'Twister'
  'Rain Dance'
  'Sunny Day'
  'Crunch'
  'Mirror Coat'
  'Psych Up'
  'ExtremeSpeed'
  'AncientPower'
  'Shadow Ball'
  'Future Sight'
  'Rock Smash'
  'Whirlpool'
  'Beat Up'
  'Fake Out'
  'Uproar'
  'Stockpile'
  'Spit Up'
  'Swallow'
  'Heat Wave'
  'Hail'
  'Torment'
  'Flatter'
  'Will-O-Wisp'
  'Memento'
  'Facade'
  'Focus Punch'
  'SmellingSalt'
  'Follow Me'
  'Nature Power'
  'Charge'
  'Taunt'
  'Helping Hand'
  'Trick'
  'Role Play'
  'Wish'
  'Assist'
  'Ingrain'
  'Superpower'
  'Magic Coat'
  'Recycle'
  'Revenge'
  'Brick Break'
  'Yawn'
  'Knock Off'
  'Endeavor'
  'Eruption'
  'Skill Swap'
  'Imprison'
  'Refresh'
  'Grudge'
  'Snatch'
  'Secret Power'
  'Dive'
  'Arm Thrust'
  'Camouflage'
  'Tail Glow'
  'Luster Purge'
  'Mist Ball'
  'FeatherDance'
  'Teeter Dance'
  'Blaze Kick'
  'Mud Sport'
  'Ice Ball'
  'Needle Arm'
  'Slack Off'
  'Hyper Voice'
  'Poison Fang'
  'Crush Claw'
  'Blast Burn'
  'Hydro Cannon'
  'Meteor Mash'
  'Astonish'
  'Weather Ball'
  'Aromatherapy'
  'Fake Tears'
  'Air Cutter'
  'Overheat'
  'Odor Sleuth'
  'Rock Tomb'
  'Silver Wind'
  'Metal Sound'
  'GrassWhistle'
  'Tickle'
  'Cosmic Power'
  'Water Spout'
  'Signal Beam'
  'Shadow Punch'
  'Extrasensory'
  'Sky Uppercut'
  'Sand Tomb'
  'Sheer Cold'
  'Muddy Water'
  'Bullet Seed'
  'Aerial Ace'
  'Icicle Spear'
  'Iron Defense'
  'Block'
  'Howl'
  'Dragon Claw'
  'Frenzy Plant'
  'Bulk Up'
  'Bounce'
  'Mud Shot'
  'Poison Tail'
  'Covet'
  'Volt Tackle'
  'Magical Leaf'
  'Water Sport'
  'Calm Mind'
  'Leaf Blade'
  'Dragon Dance'
  'Rock Blast'
  'Shock Wave'
  'Water Pulse'
  'Doom Desire'
  'Psycho Boost'
]

module.exports.NATURES = [
  'Hardy (=)'
  'Lonely (+Atk-Def)'
  'Brave (+Atk-Spe)'
  'Adamant (+Atk-SpA)'
  'Naughty (+Atk-SpD)'
  'Bold (+Def-Atk)'
  'Docile (=)'
  'Relaxed (+Def-Spe)'
  'Impish (+Def-SpA)'
  'Lax (+Def-SpD)'
  'Timid (+Spe-Atk)'
  'Hasty (+Spe-Def)'
  'Serious (=)'
  'Jolly (+Spe-SpA)'
  'Naive (+Spe-SpD)'
  'Modest (+SpA-Atk)'
  'Mild (+SpA-Def)'
  'Quiet (+SpA-Spe)'
  'Bashful (=)'
  'Rash (+SpA-SpD)'
  'Calm (+SpD-Atk)'
  'Gentle (+SpD-Def)'
  'Sassy (+SpD-Spe)'
  'Careful (-SpD-SpA)'
  'Quirky (=)'
]
