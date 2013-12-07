{ EventEmitter } = require 'events'
CLOSE_CODES = require '../const'

module.exports = class Node extends EventEmitter
  constructor: ({ @type, @open, @close }) ->
    super()
    @children or= []
    @open or= []
    @close or= []
    @length or= 0

  append: (child) ->
    @length += child.length
    @children.push child

    @emit 'append', child
    child.on 'append', (child) =>
      @length += child.length
      @emit 'append', child

  appendCodes: (codes) ->
    for code in codes
      @open.push code 
      @close.unshift CLOSE_CODES[code]

  style: ->
    @_style().join ''

  _style: ->
    throw new Error 'Not implemented'

  copy: ->
    throw new Error 'Not implemented'

  slice: (start = 0, end = Infinity) ->
    copy = @copy()

    copy.splice start, end

    return copy

  splice: ->
    throw new Error 'Not implemented'
