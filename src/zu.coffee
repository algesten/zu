{omap, curry} = require 'fnuc'
domparser = require './domparser'
selectors = require './selectors'
hasclass  = require './hasclass'

curryv = (k, v) -> curry v

module.exports = zu = omap(curryv)

    parse:     (a) -> domparser.xml a
    parseHtml: (a) -> domparser.html a

    xml:       (ns) -> domparser.renderXml ns
    html:      (ns) -> domparser.renderHtml ns
    text:      (ns) -> domparser.renderText ns
    attr:      (ns, name) -> ns[0]?.attribs?[name]
    hasClass:  (ns, name) -> return true for n in ns when hasclass(n, name); return false
    find:      (ns, sel) -> selectors.find     ns, sel
    closest:   (ns, sel) -> selectors.closest  ns, sel
    parent:    (ns, sel) -> selectors.parent   ns, sel
    next:      (ns, sel) -> selectors.next     ns, sel
    prev:      (ns, sel) -> selectors.prev     ns, sel
    siblings:  (ns, sel) -> selectors.siblings ns, sel
    children:  (ns, sel) -> selectors.children ns, sel
