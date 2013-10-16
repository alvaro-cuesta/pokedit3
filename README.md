# Pokédit3

A Pokémon (3rd generation) savegame editor library and web interface.

Based heavily on information from:

- http://bulbapedia.bulbagarden.net/wiki/Save_data_structure_in_Generation_III
- http://bulbapedia.bulbagarden.net/wiki/Pok%C3%A9mon_data_structure_in_Generation_III
- http://bulbapedia.bulbagarden.net/wiki/Pok%C3%A9mon_data_substructures_in_Generation_III
- http://bulbapedia.bulbagarden.net/wiki/Personality_value
- http://furlocks-forest.net/wiki/?page=Pokemon_GBA_Save_Format
- http://furlocks-forest.net/wiki/?page=Old/Pokemon_GBA_Save_Format
- http://furlocks-forest.net/wiki/?page=Ruby/Sapphire_Save_Data_Map
- http://datacrystal.romhacking.net/wiki/Pok%C3%A9mon_Ruby:TBL

## To Do

- Thorough mode
  - Check padding and dummy data for zeroes
  - Mark unknown bytes and dump
  - Check expected values in thorough mode
- Save comparer
- Disable checksums optionally
- Parse "other" data
- Output back to .sav
- Parsing
  - Personality
  - Pokémon data
- Read data tables from ROM
  - http://bulbapedia.bulbagarden.net/wiki/Pok%C3%A9dex_data_structure_in_Generation_III
  - http://bulbapedia.bulbagarden.net/wiki/Pok%C3%A9mon_evolution_data_structure_in_Generation_III
  - http://bulbapedia.bulbagarden.net/wiki/Pok%C3%A9mon_base_stats_data_structure_in_Generation_III  - http://bulbapedia.bulbagarden.net/wiki/Move_data_structure_in_Generation_III
  - http://bulbapedia.bulbagarden.net/wiki/Item_data_structure_in_Generation_III
  - http://bulbapedia.bulbagarden.net/wiki/Contest_data_structure_in_Generation_III
  - http://bulbapedia.bulbagarden.net/wiki/Contest_move_data_structure_in_Generation_III
  - http://bulbapedia.bulbagarden.net/wiki/Trainer_Tower_data_structures_in_Generation_III
  - http://bulbapedia.bulbagarden.net/wiki/Battle_Frontier_data_structures_in_Generation_III
- Do not print pokerus/condition in FRLG
- Web interface
- Missing data
- Advanced data
  - http://furlocks-forest.net/wiki/?page=Battle_Tower_Data
  - http://furlocks-forest.net/wiki/?page=Mossdeep_Trainer_Data
  - http://furlocks-forest.net/wiki/?page=Secret_Base_Data
  - http://furlocks-forest.net/wiki/?page=Mystery_Event_Data

## License

Copyright Álvaro Cuesta and other Pokédit3 contributors. All rights reserved.
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to
deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
IN THE SOFTWARE.
