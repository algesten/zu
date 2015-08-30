clonein = (src, dst, offs) ->
    l = src.length
    dst[offs + l] = src[l] while l--
    dst

arrclone = (a)       -> clonein a, new Array(a.length), 0

module.exports = {clonein, arrclone}
