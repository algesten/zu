
walk = (nodes, fn) ->
    for n in nodes
        fn n
        walk n.children, fn if n.children
    null

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

depthof = (n) ->
    if n
        if n._depth then n._depth else n._depth = 1 + depthof(n.parent)
    else
        0

# max depth of the list of nodes or 0
maxdepth = (nodes) -> nodes.reduce (d, n) ->
    Math.max d, depthof(n)
, 0

#         div
#        /   \
#       b    span.c
#            /   \
#           i    span.d

matchupdomlvl = (nodes, ast, depth) -> for n, i in nodes when depth < 0 or depth == depthof(n)
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

# div > span.c span.d
#
#      desc
#     /    \
#   child   span.d
#  /    \
# div  span.c

# > span.d
#
#      child
#     /    \
#   null    span.d

matchupast = (roots, parents, ast) ->
    ischild = ast.type == 'child'
    if ast.left
        parentast = if ast.left.deep then ast.left.right else ast.left
        # check dom nodes for this ast level
        matchupdom parents, parentast, ischild
        # continue up? the ast (if there is a continuation)
        if ast.left.deep
            upparent parents # move parents up
            matchupast roots, parents, ast.left
    else
        # only keep those parents that are one of the roots.
        # this is for immediate child expressions "> div"
        for n, i in parents
            parents[i] = null unless roots.indexOf(n) >= 0
    null


upparent = (nodes) -> nodes[i] = n?.parent for n, i in nodes

module.exports = (nodes, ast) ->

    startnodes = []
    if ast.deep
        # recursively match nodes that are potential
        # starting points.
        walk nodes, match(ast.right, startnodes)
    else
        # one level?
        walk nodes, match(ast, startnodes)
        return startnodes

    # parents array will be modified to hold nodes that are kept.
    parents = startnodes.map (n) -> n.parent
    matchupast nodes, parents, ast

    # keep startnodes for parents that passed matching
    startnodes.reduce (coll, n, i) ->
        coll.push n if parents[i]
        coll
    , []
