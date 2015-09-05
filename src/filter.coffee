
module.exports = filter = (as, f) -> # filter with v, i
    r = []
    ri = -1
    (r[++ri] = v if f(v, i)) for v, i in as
    r
