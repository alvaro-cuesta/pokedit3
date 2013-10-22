bufferWrite = (size) -> (inBuffer, outBuffer, offset, noAssert) ->
  inBuffer.copy outBuffer, offset, 0, size
  size

module.exports.Int8 =
  read: (buffer, offset = 0, noAssert = false) ->
    bytesRead: 1
    value: buffer.readInt8 offset, noAssert
  write: (value, buffer, offset = 0, noAssert = false) ->
    buffer.writeInt8 value, offset, noAssert
    1

module.exports.UInt8 =
  read: (buffer, offset = 0, noAssert = false) ->
    bytesRead: 1
    value: buffer.readUInt8 offset, noAssert
  write: (value, buffer, offset = 0, noAssert = false) ->
    buffer.writeUInt8 value, offset, noAssert
    1

module.exports.Int17LE =
  read: (buffer, offset = 0, noAssert = false) ->
    bytesRead: 2
    value: buffer.readInt16LE offset, noAssert
  write: (value, buffer, offset = 0, noAssert = false) ->
    buffer.writeInt16LE value, offset, noAssert
    2

module.exports.Int16BE =
  read: (buffer, offset = 0, noAssert = false) ->
    bytesRead: 2
    value: buffer.readInt16BE offset, noAssert
  write: (value, buffer, offset = 0, noAssert = false) ->
    buffer.writeInt16BE value, offset, noAssert
    2

module.exports.UInt16LE =
  read: (buffer, offset = 0, noAssert = false) ->
    bytesRead: 2
    value: buffer.readUInt16LE offset, noAssert
  write:(value, buffer, offset = 0, noAssert = false) ->
    buffer.writeUInt16LE value, offset, noAssert
    2

module.exports.UInt16BE =
  read: (buffer, offset = 0, noAssert = false) ->
    bytesRead: 2
    value: buffer.readUInt16BE offset, noAssert
  write: (value, buffer, offset = 0, noAssert = false) ->
    buffer.writeUInt16BE value, offset, noAssert
    2

module.exports.Int32LE =
  read: (buffer, offset = 0, noAssert = false) ->
    bytesRead: 4
    value: buffer.readInt32LE offset, noAssert
  write: (value, buffer, offset = 0, noAssert = false) ->
    buffer.writeInt32LE value, offset, noAssert
    4

module.exports.Int32BE =
  read: (buffer, offset = 0, noAssert = false) ->
    bytesRead: 4
    value: buffer.readInt32BE offset, noAssert
  write:(value, buffer, offset = 0, noAssert = false) ->
    buffer.writeInt32BE value, offset, noAssert
    4

module.exports.UInt32LE =
  read: (buffer, offset = 0, noAssert = false) ->
    bytesRead: 4
    value: buffer.readUInt32LE offset, noAssert
  write: (value, buffer, offset = 0, noAssert = false) ->
    buffer.writeUInt32LE value, offset, noAssert
    4

module.exports.UInt32BE =
  read: (buffer, offset = 0, noAssert = false) ->
    bytesRead: 4
    value: buffer.readUInt32BE offset, noAssert
  write: (value, buffer, offset = 0, noAssert = false) ->
    buffer.writeUInt32BE value, offset, noAssert
    4

module.exports.FloatLE =
  read: (buffer, offset = 0, noAssert = false) ->
    bytesRead: 4
    value: buffer.readFloatLE offset, noAssert
  write:(value, buffer, offset = 0, noAssert = false) ->
    buffer.writeFloatLE value, offset, noAssert
    4

module.exports.FloatBE =
  read: (buffer, offset = 0, noAssert = false) ->
    bytesRead: 4
    value: buffer.readFloatBE offset, noAssert
  write: (value, buffer, offset = 0, noAssert = false) ->
    buffer.writeFloatBE value, offset, noAssert
    4

module.exports.DoubleLE =
  read: (buffer, offset = 0, noAssert = false) ->
    bytesRead: 8
    value: buffer.readDoubleLE offset, noAssert
  write: (value, buffer, offset = 0, noAssert = false) ->
    buffer.writeDoubleLE value, offset, noAssert
    8

module.exports.DoubleBE =
  read: (buffer, offset = 0, noAssert = false) ->
    bytesRead: 8
    value: buffer.readDoubleBE offset, noAssert
  write:(value, buffer, offset = 0, noAssert = false) ->
    buffer.writeDoubleBE value, offset, noAssert
    8

module.exports.ArrayOf = (size, spec) ->
  read: (buffer, offset = 0, noAssert = false) ->
    originalOffset = offset
    elements = for i in [0...size]
      {bytesRead, value} = spec.read buffer, offset, noAssert
      offset += bytesRead
      value
    bytesRead: offset - originalOffset
    value: elements
  write: (array, buffer, offset = 0, noAssert = false) ->
    throw new Error 'Not implemented yet'  # TODO

module.exports.ArrayLiteral = (specs) ->
  read: (buffer, offset = 0, noAssert = false) ->
    originalOffset = offset
    elements = for spec in specs
      {bytesRead, value} = spec.read buffer, offset, noAssert
      offset += bytesRead
      value
    bytesRead: offset - originalOffset
    value: elements
  write: (array, buffer, offset = 0, noAssert = false) ->
    throw new Error 'Not implemented yet'  # TODO

module.exports.Slice = (size) ->
  read: (buffer, offset = 0, noAssert = false) ->
    realSize = size ? buffer.length - offset
    bytesRead: realSize
    value: buffer.slice offset, offset + realSize
  write: ->
    bufferWrite (size ? buffer.length - offset)

module.exports.Copy = (size) ->
  read: (buffer, offset = 0, noAssert = false) -> (o) ->
    result = new Buffer size
    buffer.copy result, 0, offset, offset + size
    bytesRead: size
    value: result
  write: bufferWrite size

module.exports.Skip = (size) ->
  read: -> bytesRead: size
  write: -> size

module.exports.String = (length, encoding) ->
  read: (buffer, offset = 0, noAssert = false) ->
    throw new Error 'Not implemented yet'
    # TODO: noAssert
    # buf.toString([encoding], [start], [end])
  write: (string, buffer, offset = 0, noAssert = false) ->
    throw new Error 'Not implemented yet'
    # TODO: noAssert
    #  buffer.write string, offset, length, encoding

module.exports.Obj = (spec) ->
  read: (buffer, offset = 0, noAssert = false) ->
    originalOffset = offset
    data = {}

    for definition in spec
      name = (Object.keys definition)[0]
      result = definition[name].read buffer, offset, noAssert

      if result.bytesRead?
        offset += result.bytesRead
        data[name] = result.value
      else
        offset += result

    bytesRead: offset - originalOffset
    value: data
  write: (object, buffer, offset = 0, noAssert = false) ->
    for definition in spec
      name = (Object.keys definition)[0]
      offset += definition[name].write object[name], buffer, offset, noAssert
    offset

module.exports.Wrap = ->
  captured = []

  capture: (type) ->
    read: (buffer, offset = 0, noAssert = false) ->
      result = type.read buffer, offset, noAssert
      captured.push result.value
      result
    write: (value, buffer, offset = 0, noAssert = false) ->
      captured.push value
      type.write value, buffer, offset, noAssert
  emit: (fn) ->
    read: (buffer, offset = 0, noAssert = false)  ->
      (fn captured).read buffer, offset, noAssert
    write: (value, buffer, offset = 0, noAssert = false) ->
      (fn captured).write value, buffer, offset noAssert

module.exports.Transform = (type, readFn, writeFn) ->
  read: (buffer, offset = 0, noAssert = false)  ->
    result = type.read buffer, offset, noAssert
    result.value = readFn result.value
    result
  write: (value, buffer, offset = 0, noAssert = false) ->
    fn = writeFn ? readFn
    type.write (fn value), buffer, offset, noAssert

module.exports.Filter = (fn, type) ->
  read: (buffer, offset = 0, noAssert = false)  ->
    {bytesRead, value} = type.read buffer, offset, noAssert
    bytesRead: bytesRead
    value: value.filter fn
  write: (value, buffer, offset = 0, noAssert = false) ->
    throw new Error "Not implemented yet"

module.exports.Map = (fn, type) ->
  read: (buffer, offset = 0, noAssert = false)  ->
    {bytesRead, value} = type.read buffer, offset, noAssert
    bytesRead: bytesRead
    value: value.map fn
  write: (value, buffer, offset = 0, noAssert = false) ->
    throw new Error "Not implemented yet"

module.exports.Pass = (outType, inType) ->
  read: (buffer, offset = 0, noAssert = false)  ->
    {bytesRead, value} = inType.read buffer, offset, noAssert
    bytesRead: bytesRead
    value: (outType.read value, 0, noAssert).value
  write: (value, buffer, offset = 0, noAssert = false) ->
    throw new Error "Not implemented yet"
