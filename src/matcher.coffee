{arrclone} = require './arr'

walk = (nodes, down, fn) ->
    q = arrclone nodes
    while q.length
        cn = q.shift()
        fn cn
        if down and cn.children
            len = q.length
            q[len + i] = cn.children[i] for i in [0...cn.children.length] by 1

astdesc  = (ast) -> if ast?.deep then ast.type == 'descend' or astdesc(ast.left) else false
astdepth = (ast) -> if ast?.deep then 1 + astdepth ast.left else 0

# XXX possible to optimize to avoid compiling new regexp
hasclass = (n, clz) -> !!n.attribs?.class.match RegExp "(^| )#{clz}($| )"
isId = (n, id) -> n.attribs?.id == id

evl = (n, ast) ->
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

# recurse down and collect nodes at certain depth
atdepth = (nodes, depth, coll=[]) ->
    return coll unless nodes
    for n in nodes
        coll.push n if n._depth == depth
        atdepth n.children, depth, coll
    coll

# max depth of the list of nodes or 0
maxdepth = (nodes) -> nodes.reduce (d, n) ->
    Math.max d, (n?._depth ? 0)
, 0

#         div
#        /   \
#       b    span.c
#            /   \
#           i    span.d

matchupdomlvl = (nodes, ast, depth) -> for n, i in nodes when depth < 0 or depth == n?._depth
    continue unless n
    # run match if not already done
    n._match = evl n, ast unless typeof n._match == 'boolean'
    unless n._match
        if depth >= 0
            # move to parent for next round of lvl matching
            nodes[i] = n.parent
        else
            # discard for immediate
            nodes[i] = null

    null

# remove _match flag from node and all parents
unmatchflag = (n) ->
    return unless n
    delete n._match
    unmatchflag n.parent

matchupdom = (nodes, ast, immediate) ->
    # delete any match flags
    nodes.forEach unmatchflag
    if immediate
        # immediate descendant
        matchupdomlvl nodes, ast, -1
    else
        # gradually match up from bottom
        depth = maxdepth(nodes)
        loop
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

module.exports = (nodes, ast, down=true) ->

    startnodes = []
    if ast.deep and down
        markdepth nodes # mark depth in tree
        # start from astdepth level and down
        walk (atdepth nodes, astdepth(ast)), true, match(ast.right, startnodes)
    else
        # one level?
        walk nodes, down, match(ast, startnodes)
        return startnodes

    # parents array will be modified to hold nodes that are kept.
    parents = startnodes.map (n) -> n.parent
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
