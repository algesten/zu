{keys, get, set, map, omap, curry, mixin, sequence} = require 'fnuc'
domparser = require './domparser'
selectors = require './selectors'
hasclass  = require './hasclass'

# pick the second argument
arg2 = (a1, a2) -> a2

# wrap the first argument to fn in an array, if it isn't an array.
arrfirst = (fn) -> (as...) ->
    as[0] = [v] unless Array.isArray v = as[0]
    fn as...

# fn can be partially applied either with an array or an expression.
withcurry = (fn) -> (a) -> if Array.isArray a then ((exp) -> fn a, exp) else ((ns)  -> fn ns, a)

# turn k, v into {k:v}
keyval = (k, v) -> set {}, k, v

# for an object a:fn make an object with {a:fn, aWith:withcurry(fn)}
# for each k/v pair.
withify = (o) -> mixin (map keys(o), (k) ->
    fn = arrfirst get o, k
    mixin keyval(k, fn), keyval("#{k}With", withcurry(fn))
    )...

module.exports = zu = mixin {
    parseXml:  (a) -> domparser.xml a
    parseHtml: (a) -> domparser.html a
    }, (omap(sequence arg2, arrfirst)
        xml:       (ns) -> domparser.renderXml ns
        html:      (ns) -> domparser.renderHtml ns
        text:      (ns) -> domparser.renderText ns
    ), (withify
        attr:      (ns, name) -> ns[0]?.attribs?[name]
        hasClass:  (ns, name) -> return true for n in ns when hasclass(n, name); return false
    ), (withify
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
    )
