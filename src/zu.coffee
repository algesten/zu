{omap, curry, mixin} = require 'fnuc'
domparser = require './domparser'
selectors = require './selectors'
hasclass  = require './hasclass'

currykv = (k, v) -> curry v

# special curry that allows the following forms
#    find(ns, sel)             // apply find(ns, sel)
#    find(ns)                  // apply find(ns, null)
#    find(sel)                 // return (ns) -> fn(ns, sel)
curryish = (k, fn) -> cfn = (ns, sel) ->
    if arguments.length == 0
        cfn
    else if arguments.length == 1
        if Array.isArray ns
            fn ns, null
        else
            sel = ns
            (ns) -> fn ns, sel
    else
        fn ns, sel

module.exports = zu = mixin {
    parseXml:  (a) -> domparser.xml a
    parseHtml: (a) -> domparser.html a
    xml:       (ns) -> domparser.renderXml ns
    html:      (ns) -> domparser.renderHtml ns
    text:      (ns) -> domparser.renderText ns
    }, (omap(currykv)
        attr:      (ns, name) -> ns[0]?.attribs?[name]
        hasClass:  (ns, name) -> return true for n in ns when hasclass(n, name); return false
    ), (omap(curryish)
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
