{each, fold, map, curry} = require 'fnuc'

clonein = (src, dst, offs) ->
    l = src.length
    dst[offs + l] = src[l] while l--
    dst

arrappend = (a1, a2) -> clonein a2, a1, a1.length
arrclone = (a)       -> clonein a, new Array(a.length), 0

walk = (nodes, down, fn) ->
    q = arrclone nodes
    while q.length
        cn = q.shift()
        fn cn
        if down
            len = q.length
            q[len + i] = cn.children[i] for i in [0...cn.children.length] by 1

astdesc  = (ast) -> if ast?.deep then ast.type == 'descend' or desc(ast.left) else false
astdepth = (ast) -> if ast?.deep then 1 + astdepth ast.left else 0

hasclass = (n, clz) -> !!n.attribs?.class.match RegExp "(^| )#{clz}($| )"
isId = (n, id) -> n.attribs?.id == id

evl = curry (n, ast) ->
    if !ast
        return true
    else if ast.type == 'word'
        unless n.name == ast.token.word then false else true and evl(n, ast.right)
    else if ast.type == 'id'
        unless isId(n, ast.right.token.word) then false else true and evl(n, ast.right.right)
    else if ast.type == 'class'
        unless hasclass(n, ast.right.token.word) then false else true and evl(n, ast.right.right)

match = (ast, coll) -> (n) -> coll.push n if evl(n, ast)

# write the (relative) node depth at each node in the tree
markdepth = (nodes, d=0) ->
    return unless nodes
    for n in nodes
        n._depth = d
        markdepth n.children, d+1
    null

# find unique nodes at certain depth. -1 to disregard depth
keepdepth = (nodes, depth) ->
    fold nodes, (coll, n) ->
        coll.push n if ((depth < 0) or n?._depth == depth) and coll.indexOf(n) < 0
        coll
    , []

# recurse down and collect nodes at certain depth
atdepth = (nodes, depth, coll=[]) ->
    return coll unless nodes
    for n in nodes
        coll.push n if n._depth == depth
        atdepth n.children, depth, coll
    coll

maxdepth = (nodes) -> fold nodes, (d, n) ->
    Math.max d, (n?._depth ? 0)
, 0

#         div
#        /   \
#       b    span.c
#            /   \
#           i    span.d

matchupdomlvl = (nodes, ast, depth) -> for n, i in nodes when depth < 0 or depth == n?._depth
    console.log 'lvl', depth, nodes
    continue unless n
    # run match if not already done
    console.log 'lvl already matching', n._match
    n._match = evl n, ast unless typeof n._match == 'boolean'
    console.log 'lvl is match', n._match
    unless n._match
        # move to parent for next round of lvl matching
        nodes[i] = n.parent
    null

unmatchflag = (n) ->
    return unless n
    delete n._match
    unmatchflag n.parent

matchupdom = (nodes, ast, immediate) ->
    console.log 'dom start'
    # delete any match flags
    each nodes, unmatchflag
    if immediate
        console.log 'dom immediate'
        # immediate descendant
        matchupdomlvl nodes, ast, -1
    else
        # gradually match up from bottom
        depth = maxdepth(nodes)
        loop
            console.log 'dom', depth
            matchupdomlvl nodes, ast, depth
            break if depth-- == 0
    null

#      desc
#     /    \
#   desc    span.d
#  /    \
# div  span.c

matchupast = (parents, ast) ->
    ischild = ast.type == 'child'
    parentast = if ast.left.deep then ast.left.right else ast.left
    # check dom nodes for this ast level
    matchupdom parents, parentast, ischild
    # continue up? the ast (if there is a continuation)
    if ast.left.deep
        upparent parents # move parents up
        matchupast parents, ast.left
    null


upparent = (nodes) -> nodes[i] = n?.parent for n, i in nodes

module.exports = (nodes, ast) ->

    hasdesc = astdesc(ast) or !ast.deep

    startnodes = []
    if ast.deep
        markdepth nodes # mark depth in tree
        walk (atdepth nodes, astdepth(ast)), hasdesc, match(ast.right, startnodes)
    else
        # one level?
        walk nodes, true, match(ast, startnodes)
        return startnodes

    # parents array will be modified to hold nodes that are kept.
    parents = map startnodes, (n) -> n.parent
    matchupast parents, ast

    # XXX
    # keep startnodes for parents
    startnodes.reduce (coll, n, i) ->
        coll.push n if parents[i]
        coll
    , []


# { type: 'tag',
#     name: 'span',
#     attribs: { class: 'd' },
#     children: [],
#     next: ...
#     prev: ...
#     parent: ...
#     toString: [Function],
#     _depth: 2 }
