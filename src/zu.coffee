{omap} = require 'fnuc'
domparser = require './domparser'
selectors = require './selectors'

zu = (a) ->
    if typeof a == 'string'
        wrap domparser.xml a
    else if Array.isArray a
        wrap a
    else
        throw new Error("What to do with: " + a)

# wrap some nodes with zu functions
wrap = (nodes) -> if nodes.isZu then nodes else Object.defineProperties nodes, fn

# function to expose on every object
zufn = omap (k, v) -> value:v
fn = zufn
    isZu: true
    xml:  -> domparser.renderXml  this
    html: -> domparser.renderHtml this
    text: -> domparser.renderText this
    find:     (sel) -> wrap selectors.find     this, sel
    closest:  (sel) -> wrap selectors.closest  this, sel
    parent:   (sel) -> wrap selectors.parent   this, sel
    next:     (sel) -> wrap selectors.next     this, sel
    prev:     (sel) -> wrap selectors.prev     this, sel
    siblings: (sel) -> wrap selectors.siblings this, sel
    children: (sel) ->
    attr:     (name) ->
    data:     (name) ->
    hasClass: (name) ->

module.exports = zu
