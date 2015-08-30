{omap, map, filter, I, uniq, sequence} = require 'fnuc'
domparser = require './domparser'
matcher   = require './matcher'
parser    = require './parser'

defined = filter I

zu = (a) ->
    if typeof a == 'string'
        wrap domparser.xml a
    else if Array.isArray a
        wrap a
    else
        throw new Error("What to do with: " + a)

# wrap some nodes with zu functions
wrap = (nodes) -> if nodes.isZu then nodes else Object.defineProperties nodes, fn

# keep only defined unique nodes
dedup = sequence uniq, defined

# function to expose on every object
propify = (k, v) -> value:v
fn = omap(propify)
    isZu: true
    find: (e) -> wrap matcher this, parser(e)()
    parent: -> wrap dedup map this, (n) -> n.parent

module.exports = zu
