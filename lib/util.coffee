TERMINATOR = 0xFF
CHARS = [
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '!', '?', '.', '-', undefined,
  '…', '“', '”', '‘', '’', '♂', '♀', undefined, ',', undefined, '/', 'A', 'B', 'C', 'D', 'E',
  'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U',
  'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k',
  'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
]

CHARSET = []
CHARSET[i + 0xA1] = char for char, i in CHARS
CHARSET[0xFB] = '\u25B6'
CHARSET[0xFE] = '\n'
CHARSET[0xFF] = TERMINATOR
module.exports.CHARSET = CHARSET

module.exports.decodeString = (buffer, start, length) ->
  result = ''
  for i in [start..(start + length - 1)]
    val = CHARSET[buffer.readUInt8 i]
    return result if val == TERMINATOR
    result += val
