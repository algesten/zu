escre    = require './escre'
hasclass = require './hasclass'

isId = (n, id) -> n.attribs?.id == id

# evaluate attribute selector
evlattr = (n, ast) ->
    nv = n?.attribs[ast.attr]
    if ast.attrtype == 'exists'
        !!nv
    else if ast.attrtype == 'equals'
        nv == ast.attrval
    else if ast.attrtype == 'white'
        !!nv?.match RegExp "(^| )#{escre ast.attrval}($| )"
    else if ast.attrtype == 'hyphen'
        !!nv?.match RegExp "^#{escre ast.attrval}($|-)"
    else if ast.attrtype == 'begin'
        nv?.indexOf(ast.attrval) == 0
    else if ast.attrtype == 'end'
        !!nv?.match RegExp "#{escre ast.attrval}$"
    else if ast.attrtype == 'substr'
        nv?.indexOf(ast.attrval) >= 0
    else
        false

evl = (n, ast) ->
    if !ast
        return true
    else if ast.type == 'word'
        unless n.name == ast.token.word then false else evl(n, ast.right)
    else if ast.type == 'id'
        unless isId(n, ast.word)        then false else evl(n, ast.right)
    else if ast.type == 'class'
        unless hasclass(n, ast.word)    then false else evl(n, ast.right)
    else if ast.type == 'attrib'
        unless evlattr(n, ast)          then false else evl(n, ast.right)

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
        # the ast to check parents against
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

# the matcher expects to be given nodes that are already selected
# against the lowest level (right most) level in the ast. it
# will only check parent nodes working up the ast tree.
module.exports = matcher = (roots, nodes, ast) ->

    # no expression? just return start nodes
    return nodes unless ast?.deep

    # parents array will be modified to hold nodes that are kept.
    parents = nodes.map (n) -> n.parent
    matchupast roots, parents, ast

    # keep nodes for parents that passed matching
    nodes.reduce (coll, n, i) ->
        coll.push n if parents[i]
        coll
    , []

# expose evl
matcher.evl = evl
