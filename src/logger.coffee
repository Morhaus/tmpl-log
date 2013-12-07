{ DEFAULT_TAGS, CLOSE_CODES } = require './const'
TagNode = require './node/tag'
TextNode = require './node/text'

module.exports = class Logger
  constructor: (options = {}) ->
    @options = {}
    @options[name] = value for own name, value of options

    @_tags = {}
    @_tags[name] = value[..] for name, value of DEFAULT_TAGS

    @_events = {}
    @_modes = {}

    @options.tab or= 6
    @options.gutter = ' - ' if not @options.gutter and @options.gutter isnt ''
    @options.gutter = @parse @options.gutter

  log: (data, options = {}) =>
    { colors, depth, showHidden } = options
    colors ?= true

    if typeof data is 'string'
      console.log @format data
    else if typeof data in ['object', 'number']
      console.log (util.inspect data, { depth, showHidden, colors })
    else
      console.log data

    return @

  emit: (event, data) =>
    return if @_mode? and @_modes[@_mode] isnt true and (@_mode is false or event not in @_modes[@_mode])

    event = @_events[event] or (@parse event)
    data = @format data

    output = []

    dataLines = data.split '\n'
    eventLines =
      for i in [0...(Math.ceil event.length / @options.tab)]
        event.slice i * @options.tab, (i + 1) * @options.tab

    tabsSpace = (new Array @options.tab + 1).join(' ')
    gutterSpace = (new Array @options.gutter.length + 1).join(' ')
    gutter = @options.gutter.style()

    for i in [0...(Math.max dataLines.length, eventLines.length)]
      line = []
      eventLine = eventLines[i]
      dataLine = dataLines[i]

      if eventLine
        line.push (new Array @options.tab - eventLine.length + 1).join(' ')
        line.push eventLine.style()
      else
        line.push tabsSpace

      line.push if i is 0 then gutter else gutterSpace
      line.push dataLine

      output.push (line.join '')

    console.log (output.join '\n')

    return @

  format: (str) =>
    (@parse str).style()

  parse: (str) ->
    reg = /<\/?[a-zA-Z0-9-]*>/g

    output = []
    lastIndex = 0
    matchesLength = 0

    tree = []

    root = new TagNode 'root',
      open: @_tags.default[..] or []
      close: (CLOSE_CODES[code] for code in @_tags.default by -1)

    tree.unshift root

    while match = reg.exec str
      { 0: match, index } = match

      # Create a text node with the text in between the two tags.
      tree[0].append new TextNode str[lastIndex...index] if str[lastIndex...index] isnt ''
      lastIndex = index + match.length

      open = match[1] isnt '/'
      tag = if open then match[1...-1] else match[2...-1]

      if open
        node = new TagNode tag
        tree[0].append node

        # Retrieve codes associated with this tag
        throw new Error "Non-existent style #{tag} at index #{index}" if tag not of @_tags
        node.appendCodes @_tags[tag]

        tree.unshift node

      # Else, close the node by removing it from the tree.
      else
        node = tree.shift()

        throw new Error "Expected </#{node.name}> or </> closing tag, received </#{tag}> instead at index #{index}" if node.name isnt tag and match isnt '</>'

    # Create a text node with the remaining text
    tree[0].append new TextNode str[lastIndex..]

    return root

  setMode: (mode) ->
    throw (new Error "Unknown mode (#{mode})") if mode not of @_modes
    @_mode = mode
    return @

  registerMode: (name, events) ->
    @_mode or= name if name is 'default'
    @_modes[name] = events
    return @

  registerEvent: (name, display) ->
    @_events[name] = @parse display
    return @

  registerTag: (name, tags) ->
    @_tags[name] = [].concat (@_tags[tag] for tag in tags)...
    return @

module.exports = Logger
