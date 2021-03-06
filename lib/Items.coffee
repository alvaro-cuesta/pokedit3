{UInt16LE, ArrayOf, Obj, Transform, Filter} = require "#{__dirname}/byte-spec"

module.exports = (size, key = 0) -> Filter ((v) -> v.id != 0), ArrayOf size, Obj [
  {id: UInt16LE}
  {qty: Transform UInt16LE, (v) -> v ^ (key & 0xFFFF)}
]

module.exports.NAMES = [
  undefined
  'Master Ball'
  'Ultra Ball'
  'Great Ball'
  'Poké Ball'
  'Safari Ball'
  'Net Ball'
  'Dive Ball'
  'Nest Ball'
  'Repeat Ball'
  'Timer Ball'
  'Luxury Ball'
  'Premier Ball'
  'Potion'
  'Antidote'
  'Burn Heal'
  'Ice Heal'
  'Awakening'
  'Parlyz Heal'
  'Full Restore'
  'Max Potion'
  'Hyper Potion'
  'Super Potion'
  'Full Heal'
  'Revive'
  'Max Revive'
  'Fresh Water'
  'Soda Pop'
  'Lemonade'
  'Moomoo Milk'
  'EnergyPowder'
  'Energy Root'
  'Heal Powder'
  'Revival Herb'
  'Ether'
  'Max Ether'
  'Elixir'
  'Max Elixir'
  'Lava Cookie'
  'Blue Flute'
  'Yellow Flute'
  'Red Flute'
  'Black Flute'
  'White Flute'
  'Berry Juice'
  'Sacred Ash'
  'Shoal Salt'
  'Shoal Shell'
  'Red Shard'
  'Blue Shard'
  'Yellow Shard'
  'Green Shard'
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  'HP Up'
  'Protein'
  'Iron'
  'Carbos'
  'Calcium'
  'Rare Candy'
  'PP Up'
  'Zinc'
  'PP Max'
  undefined
  'Guard Spec.'
  'Dire Hit'
  'X Attack'
  'X Defend'
  'X Speed'
  'X Accuracy'
  'X Special'
  'Poké Doll'
  'Fluffy Tail'
  undefined
  'Super Repel'
  'Max Repel'
  'Escape Rope'
  'Repel'
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  'Sun Stone'
  'Moon Stone'
  'Fire Stone'
  'Thunderstone'
  'Water Stone'
  'Leaf Stone'
  undefined
  undefined
  undefined
  undefined
  'TinyMushroom'
  'Big Mushroom'
  undefined
  'Pearl'
  'Big Pearl'
  'Stardust'
  'Star Piece'
  'Nugget'
  'Heart Scale'
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  'Orange Mail'
  'Harbor Mail'
  'Glitter Mail'
  'Mech Mail'
  'Wood Mail'
  'Wave Mail'
  'Bead Mail'
  'Shadow Mail'
  'Tropic Mail'
  'Dream Mail'
  'Fab Mail'
  'Retro Mail'
  'Cheri Berry'
  'Chesto Berry'
  'Pecha Berry'
  'Rawst Berry'
  'Aspear Berry'
  'Leppa Berry'
  'Oran Berry'
  'Persim Berry'
  'Lum Berry'
  'Sitrus Berry'
  'Figy Berry'
  'Wiki Berry'
  'Mago Berry'
  'Aguav Berry'
  'Iapapa Berry'
  'Razz Berry'
  'Bluk Berry'
  'Nanab Berry'
  'Wepear Berry'
  'Pinap Berry'
  'Pomeg Berry'
  'Kelpsy Berry'
  'Qualot Berry'
  'Hondew Berry'
  'Grepa Berry'
  'Tamato Berry'
  'Cornn Berry'
  'Magost Berry'
  'Rabuta Berry'
  'Nomel Berry'
  'Spelon Berry'
  'Pamtre Berry'
  'Watmel Berry'
  'Durin Berry'
  'Belue Berry'
  'Liechi Berry'
  'Ganlon Berry'
  'Salac Berry'
  'Petaya Berry'
  'Apicot Berry'
  'Lansat Berry'
  'Starf Berry'
  'Enigma Berry'
  undefined
  undefined
  undefined
  'BrightPowder'
  'White Herb'
  'Macho Brace'
  'Exp. Share'
  'Quick Claw'
  'Soothe Bell'
  'Mental Herb'
  'Choice Band'
  'King\'s Rock'
  'SilverPowder'
  'Amulet Coin'
  'Cleanse Tag'
  'Soul Dew'
  'DeepSeaTooth'
  'DeepSeaScale'
  'Smoke Ball'
  'Everstone'
  'Focus Band'
  'Lucky Egg'
  'Scope Lens'
  'Metal Coat'
  'Leftovers'
  'Dragon Scale'
  'Light Ball'
  'Soft Sand'
  'Hard Stone'
  'Miracle Seed'
  'BlackGlasses'
  'Black Belt'
  'Magnet'
  'Mystic Water'
  'Sharp Beak'
  'Poison Barb'
  'NeverMeltIce'
  'Spell Tag'
  'TwistedSpoon'
  'Charcoal'
  'Dragon Fang'
  'Silk Scarf'
  'Up-Grade'
  'Shell Bell'
  'Sea Incense'
  'Lax Incense'
  'Lucky Punch'
  'Metal Powder'
  'Thick Club'
  'Stick'
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  undefined
  'Red Scarf'
  'Blue Scarf'
  'Pink Scarf'
  'Green Scarf'
  'Yellow Scarf'
  'Mach Bike'
  'Coin Case'
  'Itemfinder'
  'Old Rod'
  'Good Rod'
  'Super Rod'
  'S.S. Ticket'
  'Contest Pass'
  undefined
  'Wailmer Pail'
  'Devon Goods'
  'Soot Sack'
  'Basement Key'
  'Acro Bike'
  'Pokéblock Case'
  'Letter'
  'Eon Ticket'
  'Red Orb'
  'Blue Orb'
  'Scanner'
  'Go-Goggles'
  'Meteorite'
  'Rm. 1 Key'
  'Rm. 2 Key'
  'Rm. 4 Key'
  'Rm. 6 Key'
  'Storage Key'
  'Root Fossil'
  'Claw Fossil'
  'Devon Scope'
  'TM01 Focus Punch'
  'TM02 Dragon Claw'
  'TM03 Water Pulse'
  'TM04 Calm Mind'
  'TM05 Roar'
  'TM06 Toxic'
  'TM07 Hail'
  'TM08 Bulk Up'
  'TM09 Bullet Seed'
  'TM10 Hidden Power'
  'TM11 Sunny Day'
  'TM12 Taunt'
  'TM13 Ice Beam'
  'TM14 Blizzard'
  'TM15 Hyper Beam'
  'TM16 Light Screen'
  'TM17 Protect'
  'TM18 Rain Dance'
  'TM19 Giga Drain'
  'TM20 Safeguard'
  'TM21 Frustration'
  'TM22 SolarBeam'
  'TM23 Iron Tail'
  'TM24 Thunderbolt'
  'TM25 Thunder'
  'TM26 Earthquake'
  'TM27 Return'
  'TM28 Dig'
  'TM29 Psychic'
  'TM30 Shadow Ball'
  'TM31 Brick Break'
  'TM32 Double Team'
  'TM33 Reflect'
  'TM34 Shock Wave'
  'TM35 Flamethrower'
  'TM36 Sludge Bomb'
  'TM37 Sandstorm'
  'TM38 Fire Blast'
  'TM39 Rock Tomb'
  'TM40 Aerial Ace'
  'TM41 Torment'
  'TM42 Facade'
  'TM43 Secret Power'
  'TM44 Rest'
  'TM45 Attract'
  'TM46 Thief'
  'TM47 Steel Wing'
  'TM48 Skill Swap'
  'TM49 Snatch'
  'TM50 Overheat'
  'HM01 Cut'
  'HM02 Fly'
  'HM03 Surf'
  'HM04 Strength'
  'HM05 Flash'
  'HM06 Rock Smash'
  'HM07 Waterfallin'
  'HM08 Dive'
  undefined
  undefined
  'Oak\'s Parcel'
  'Poké Flute'
  'Secret Key'
  'Bike Voucher'
  'Gold Teeth'
  'Old Amber'
  'Card Key'
  'Lift Key'
  'Dome Fossil'
  'Helix Fossil'
  'Silph Scope'
  'Bicycle'
  'Town Map'
  'Vs. Seeker'
  'Fame Checker'
  'TM Case'
  'Berry Pouch'
  'Teachy TV'
  'Tri-Pass'
  'Rainbow Pass'
  'Tea'
  'MysticTicket'
  'AuroraTicket'
  'Powder Jar'
  'Ruby'
  'Sapphire'
  'Magma Emblem'
  'Old Sea Map'
]
