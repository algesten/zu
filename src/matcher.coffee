{map, firstfn} = require 'fnuc'
filter    = require './filter'
escre     = require './escre'
hasclass  = require './hasclass'
{text}    = require('./domparser').output

isId = (n, id) -> n.attribs?.id == id
onlytag = (as) -> filter as, (n) -> n.type == 'tag'

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

# evaluate pseudo selector
evlpseudo = (n, ast) ->
    if ast.pseudotype == 'contains'
        text(n).indexOf(ast.pseudoval) >= 0
    else if ast.pseudotype == 'empty'
        !n?.children?.length or !firstfn n.children, (c) -> c.type == 'tag' or c.type == 'text'
    else if ast.pseudotype == 'first-child'
        if cn = n.parent?.children
            onlytag(cn).indexOf(n) == 0
    else if ast.pseudotype == 'last-child'
        if cn = n.parent?.children
            tgs = onlytag(cn)
            tgs.indexOf(n) == tgs.length - 1
    else
        false

evl = (n, ast) ->
    while ast
        if ast.type == 'word'
            return false unless n.name == ast.token.word
        else if ast.type == 'id'
            return false unless isId(n, ast.word)
        else if ast.type == 'class'
            return false unless hasclass(n, ast.word)
        else if ast.type == 'attrib'
            return false unless evlattr(n, ast)
        else if ast.type == 'pseudo'
            return false unless evlpseudo(n, ast)
        else if ast.type == 'all'
            # well. it's always good.
        else
            throw new Error("Unhandled ast type " + ast.type)
        ast = ast.right
    true

depthof = (n) ->
    if n._depth then n._depth else
        if n.parent then n._depth = 1 + depthof(n.parent) else n._depth = 0

# max depth of the list of nodes or 0
maxdepth = (nodes) ->
    max = 0
    for n in nodes when n
        max = Math.max max, depthof(n)
    max

#         div
#        /   \
#       b    span.c
#            /   \
#           i    span.d

matchupdomlvl = (nodes, ast, depth) ->
    for n, i in nodes when n and (depth == -1 or depth == (n._depth ? depthof(n)))
        # run match if not already done
        n._match = evl n, ast unless n._match?
        unless n._match
            if depth >= 0
                # move to parent for next round of lvl matching which
                # may move to undefined, if at top. this is fine.
                nodes[i] = n.parent
            else
                # discard for immediate
                nodes[i] = null
    null

# remove _match flag from node and all parents
unmatchflag = (n) ->
    loop
        delete n._match
        n = n.parent
        break unless n
    null

matchupdom = (nodes, ast, immediate) ->
    # delete any match flags
    unmatchflag(n) for n in nodes when n
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
        isleftdeep = ast.left.deep
        # the ast to check parents against
        parentast = if isleftdeep then ast.left.right else ast.left
        # check dom nodes for this ast level
        matchupdom parents, parentast, ischild
        # continue up? the ast (if there is a continuation)
        if isleftdeep
            upparent parents # move parents up
            matchupast roots, parents, ast.left
    else
        # only keep those parents that are one of the roots.
        # this is for immediate child expressions "> div"
        for n, i in parents
            parents[i] = null unless roots.indexOf(n) >= 0
    null


upparent = (nodes) ->
    nodes[i] = n.parent for n, i in nodes when n
    null

# the matcher expects to be given nodes that are already selected
# against the lowest level (rightmost) level in the ast. it will only
# check parent nodes working up the ast tree.
module.exports = matcher = (roots, nodes, ast) ->

    # no deep expression? just return start nodes
    return nodes unless ast?.deep

    # parents array will be modified to hold nodes that are kept.
    parents = map nodes, (n) -> n.parent
    matchupast roots, parents, ast

    # keep nodes for parents that passed matching
    filter nodes, (n, i) -> parents[i]

# expose evl
matcher.evl = evl
