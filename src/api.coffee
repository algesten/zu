{keys, values, converge, sequence, set,
apply, zipwith, map, mixin, flip, omap} = require 'fnuc'

domparser = require './domparser'
selectors = require './selectors'
hasclass  = require './hasclass'

# fn can be partially applied either with an array or an expression.
withcurry = (fn) -> (a) -> if Array.isArray a then ((exp) -> fn a, exp) else ((ns)  -> fn ns, a)

# turns key "foo" to "fooWith"
withkey = (k) -> "#{k}With"

withify = do ->
    zipper = zipwith (k1, k2, v) -> set(k2, withcurry(v)) set({}, k1,v)
    sequence (converge zipper, keys, sequence(keys, map(withkey)), values), apply(mixin)

arg1_str =
    parseXml:  (a) -> domparser.xml a
    parseHtml: (a) -> domparser.html a
arg1_nodes =
    xml:       (ns) -> domparser.renderXml ns
    html:      (ns) -> domparser.renderHtml ns
    text:      (ns) -> domparser.renderText ns
arg2 =
    attr:      (name, ns) -> ns[0]?.attribs?[name]
    hasClass:  (name, ns) -> return true for n in ns when hasclass(n, name); return false
    find:      (exp, ns) -> selectors.find     exp, ns
    closest:   (exp, ns) -> selectors.closest  exp, ns
    parent:    (exp, ns) -> selectors.parent   exp, ns
    parents:   (exp, ns) -> selectors.parents  exp, ns
    next:      (exp, ns) -> selectors.next     exp, ns
    nextAll:   (exp, ns) -> selectors.nextAll  exp, ns
    prev:      (exp, ns) -> selectors.prev     exp, ns
    prevAll:   (exp, ns) -> selectors.prevAll  exp, ns
    siblings:  (exp, ns) -> selectors.siblings exp, ns
    children:  (exp, ns) -> selectors.children exp, ns
    filter:    (exp, ns) -> selectors.filter   exp, ns
    is:        (exp, ns) -> selectors.is       exp, ns

module.exports = build = (inverse=true) ->
    _arg2 = if inverse then omap(arg2, (k, v) -> flip v) else arg2
    mixin arg1_str, arg1_nodes, _arg2
