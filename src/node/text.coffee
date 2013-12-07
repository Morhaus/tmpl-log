Node = require './'

module.exports = class TextNode extends Node
  constructor: (@value, opts = {}) ->
    super opts
    @type = 'text'
    @length = value.length

  _style: ->
    return [unescape @value]

  copy: ->
    copy = new TextNode @value, type: @type, open: @open[..], close: @close[..]
    return copy

  splice: (start = 0, end = Infinity) ->
    @value = @value[start...end]
    @length = @value.length

    return @
