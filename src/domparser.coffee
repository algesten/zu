{merge, replace} = require 'fnuc'
htmlparser = require 'htmlparser2'
serialize  = require 'dom-serializer'

idstr = (n) -> if s = n.attribs.id then "##{s}" else ""
dots = replace (/ /g), '.'
clstr = (n) -> if s = n.attribs.class then ".#{dots s}" else ""

toString = (n) ->
    r = ->
        if n.type == 'tag'
            "<#{n.name}#{idstr(n)}#{clstr(n)}>"
        else
            "[#{n.name}]"
    {toString:r, inspect:r}

decorate = (n) -> merge n, toString(n)

mkparser = (opts, cb) ->
    handler = new htmlparser.DomHandler cb, null, decorate
    new htmlparser.Parser(handler, merge {decodeEntities:true}, opts)

doparse = (s, opts) ->
    dom = null
    parser = mkparser opts, (err, _dom) ->
        if err then throw(err) else (dom = _dom)
    parser.write s
    parser.end()
    dom

onlywhite = do ->
    re = /^\s+$/
    (s) -> !!s.match re

renderText = (nodes) ->
    _renderText nodes, out = []
    out.join('')

_renderText = (nodes, out) ->
    for n in nodes when n
        if n.type == 'tag' and n.children
            _renderText n.children, out
        else if n.type == 'text'
            out.push n.data unless onlywhite(n.data)

output = (fn, opts) -> (nodes) ->
    return '' unless nodes
    nodes = if Array.isArray(nodes) then nodes else [nodes]
    fn nodes, opts

module.exports =
    parse:
        parseXml:  (s) -> doparse s, {xmlMode:true}
        parseHtml: (s) -> doparse s
    output:
        xml:  output serialize, xmlMode:true
        html: output serialize
        text: output renderText
