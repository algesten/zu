{merge, replace, concat, map, filter} = require 'fnuc'
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

renderText = (nodes, out) ->
    for n in nodes when n
        if n.type == 'tag' and n.children
            renderText n.children, out
        else if n.type == 'text'
            out.push n.data unless onlywhite(n.data)

onlytag = filter (n) -> n.type == 'tag'

# prepare the tree so each level has an array _desc with all
# descendants and self from that level
prepdesc = (nodes) ->
    for n in nodes when n.type == 'tag'
        if n.children
            tags = onlytag(n.children)
            prepdesc tags
            n._desc = concat n, (map tags, (c) -> c._desc)...
        else
            n._desc = [n]
    nodes


module.exports =
    parseXml:  (s) -> prepdesc doparse s, {xmlMode:true}
    parseHtml: (s) -> prepdesc doparse s
    xml:  (dom) ->
        return '' unless dom
        dom = if Array.isArray(dom) then dom else [dom]
        serialize dom, xmlMode:true
    html: (dom) ->
        return '' unless dom
        dom = if Array.isArray(dom) then dom else [dom]
        serialize dom
    text: (dom) ->
        return '' unless dom
        dom = if Array.isArray(dom) then dom else [dom]
        renderText dom, (out = []); out.join('')
