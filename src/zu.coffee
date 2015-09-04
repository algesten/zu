{zipwith, set, mixin, keys, values, converge, map, apply} = require 'fnuc'
domparser = require './domparser'
selectors = require './selectors'
hasclass  = require './hasclass'

# fn can be partially applied either with an array or an expression.
withcurry = (fn) -> (a) -> if Array.isArray a then ((exp) -> fn a, exp) else ((ns)  -> fn ns, a)

# key fooWith for foo
withk = (s) -> "#{s}With"

# for an object a:fn make an object with [{a:fn, aWith:withcurry(fn)}]
# for each k/v pair.
withify = do ->
    z = (k, fn) -> set(withk(k), withcurry(fn)) set({}, k, fn)
    converge zipwith(z), keys, values

arg1_str =
    parseXml:  (a) -> domparser.xml a
    parseHtml: (a) -> domparser.html a

arg1_nodes =
    xml:       (ns) -> domparser.renderXml ns
    html:      (ns) -> domparser.renderHtml ns
    text:      (ns) -> domparser.renderText ns

arg2 =
    attr:      (ns, name) -> (if Array.isArray(ns) then ns[0] else ns)?.attribs?[name]
    hasClass:  (ns, name) -> return true for n in ns when hasclass(n, name); return false
    find:      (ns, exp) -> selectors.find     ns, exp
    closest:   (ns, exp) -> selectors.closest  ns, exp
    parent:    (ns, exp) -> selectors.parent   ns, exp
    parents:   (ns, exp) -> selectors.parents  ns, exp
    next:      (ns, exp) -> selectors.next     ns, exp
    nextAll:   (ns, exp) -> selectors.nextAll  ns, exp
    prev:      (ns, exp) -> selectors.prev     ns, exp
    prevAll:   (ns, exp) -> selectors.prevAll  ns, exp
    siblings:  (ns, exp) -> selectors.siblings ns, exp
    children:  (ns, exp) -> selectors.children ns, exp
    filter:    (ns, exp) -> selectors.filter   ns, exp
    is:        (ns, exp) -> selectors.is       ns, exp


module.exports = zu = mixin arg1_str, arg1_nodes, withify(arg2)...
