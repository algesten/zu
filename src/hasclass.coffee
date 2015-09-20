# ripped off from jQuery hoping that is a fast implementation.
rclass = /[\t\r\n\f]/g
module.exports = hasclass = (n, clz) ->
    cname = " #{clz} "
    if (c = n.attribs?.class)
        " #{c} ".replace(rclass,' ').indexOf(cname) >= 0
    else
        false
