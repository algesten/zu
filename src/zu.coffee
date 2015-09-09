{zipwith, set, mixin, keys, values, converge, map, apply, arityof} = require 'fnuc'
domparser = require './domparser'
selectors = require './selectors'
hasclass  = require './hasclass'

# for a function fn that just accept nodes, give an extra argument
# (nodes, exp) that, if present, performs a selectors.find on that
# expression.
preselector  = (fn) -> (nodes, exp) ->
    nodes = if exp then selectors.find(nodes, exp) else nodes
    fn nodes

# for a function fn that accepts nodes and something more, gives
# extra arguments (nodes, exp, a3) that, if present, performs
# a selectors.find on that expression.
preselector3 = (fn) -> (nodes, exp, a3) ->
    if arguments.length == 2
        a3 = exp
        exp = undefined
    nodes = if exp then selectors.find(nodes, exp) else nodes
    fn nodes, a3

# fn can be partially applied either with an array or an expression.
withcurry = (fn) -> (a) ->
    if a.constructor == String then ((ns)  -> fn ns, a) else ((exp) -> fn a, exp)

# fn can be partially applied with an array + optional expression and then a string arg
withprecurry = (fn) -> (a, a2) ->
    if a.constructor == String then ((ns, exp) -> fn ns, exp, a) else ((a3) -> fn a, a2, a3)

# for an object a:fn make an object [{a:preselector(fn)}]
preselectify = do ->
    z = (k, fn) -> set {}, k, preselector(fn)
    converge zipwith(z), keys, values

# key fooWith for foo
withk = (s) -> "#{s}With"

# for an object a:fn make an object with [{a:fn, aWith:withcurry(fn)}]
# for each k/v pair.
withify = (curryfn) ->
    z = (k, fn) -> set(withk(k), curryfn(fn)) set({}, k, fn)
    converge zipwith(z), keys, values

arg1 = domparser.parse

arg2 = mixin selectors, (mixin preselectify(domparser.output)...)

arg2str =
    attr:     preselector3 (ns, name) ->
        (if Array.isArray(ns) then ns[0] else ns)?.attribs?[name]
    hasClass: preselector3 (ns, name) ->
        return true for n in ns when hasclass(n, name); return false


module.exports = zu = mixin arg1, withify(withcurry)(arg2)..., withify(withprecurry)(arg2str)...
