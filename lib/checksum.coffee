module.exports.block = (buffer, start, end) ->
  sum = 0
  (sum += buffer.readUInt32LE i) for i in [start..end] by 4
  sum = ((sum >>> 16) + (sum & 0xFFFF)) & 0xFFFF
  sum

module.exports.pokemon = (buffer) ->
  sum = 0
  (sum += buffer.readUInt16LE i) for i in [0...buffer.length] by 2
  sum &= 0xFFFF
  sum
