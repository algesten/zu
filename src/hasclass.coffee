
# XXX possible to optimize to avoid compiling new regexp
module.exports = hasclass = (n, clz) -> !!n.attribs?.class?.match RegExp "(^| )#{clz}($| )"
