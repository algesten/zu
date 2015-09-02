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
    parse:     (a) -> domparser.xml a
    parseHtml: (a) -> domparser.html a
    xml:       (ns) -> domparser.renderXml ns
    html:      (ns) -> domparser.renderHtml ns
    text:      (ns) -> domparser.renderText ns
    }, (omap(currykv)
        attr:      (ns, name) -> ns[0]?.attribs?[name]
        hasClass:  (ns, name) -> return true for n in ns when hasclass(n, name); return false
    ), (omap(curryish)
        find:      (ns, sel) -> selectors.find     ns, sel
        closest:   (ns, sel) -> selectors.closest  ns, sel
        parent:    (ns, sel) -> selectors.parent   ns, sel
        parents:   (ns, sel) -> selectors.parents  ns, sel
        next:      (ns, sel) -> selectors.next     ns, sel
        nextAll:   (ns, sel) -> selectors.nextAll  ns, sel
        prev:      (ns, sel) -> selectors.prev     ns, sel
        prevAll:   (ns, sel) -> selectors.prevAll  ns, sel
        siblings:  (ns, sel) -> selectors.siblings ns, sel
        children:  (ns, sel) -> selectors.children ns, sel
        is:        (ns, sel) -> selectors.is       ns, sel
    )
