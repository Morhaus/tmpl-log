Node = require './'

module.exports = class TagNode extends Node
  constructor: (@name, opts = {}) ->
    super opts
    @type = 'tag'

  _style: ->
    return if @children.length is 0
    output = []

    # Apply open codes.
    output.push code for code in @open

    # Push child nodes.
    for childNode in @children
      output = output.concat childNode._style()
      # Reapply own styles
      output = output.concat @open

    # Apply close codes.
    output.push code for code in @close

    return output

  copy: ->
    copy = new TagNode @tag, type: @type, open: @open[..], close: @close[..]
    copy.append child.copy() for child in @children 
    return copy

  splice: (start = 0, end = Infinity) ->
    index = 0

    for child, i in @children
      newIndex = index + child.length
      if index + child.length < start
        @children.shift()
        @length -= child.length

      else
        if newIndex >= end
          @length -= child.length
          child.splice 0, end - index
          @length += child.length

        if start > index and start < newIndex
          @length -= child.length
          child.splice start - index
          @length += child.length

        if newIndex == end
          break

    return @
