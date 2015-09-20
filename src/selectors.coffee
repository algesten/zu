{uniq}  = require 'fnuc'
matcher = require './matcher'
parser  = require './parser'
{evl}   = matcher

# when collecting nodes we do tests against the lowest
# level in a selector expressions. this forms a starting
# point for executing the entire ast using the matcher.
collector = (ast, nodes) ->
    # ast.deep means a child/descend expression
    lst = if ast?.deep then ast.right else ast
    (n) -> nodes[nodes.length] = n if evl(n, lst)

parse = (exp) -> parser(exp)()

exec = (walk, pre, emptyast) -> (roots, exp) ->
    ast = parse exp
    return [] if emptyast and !ast
    # no nodes? you get what you give.
    return roots unless roots
    # we allow passing in nodes not in arrays
    roots = if roots instanceof Array then roots else [roots]
    # collection of nodes that are starting points for
    # matching the entire ast
    nodes = []
    # collector function that matches the rightmost part
    # of the ast and adds it to nodes if we have a match
    coll = collector ast, nodes
    walk roots, coll
    # run entire ast match on starting points
    matcher roots, (if pre then pre(nodes) else nodes), ast

tagnext = (n) ->
    loop
        n = n.next
        break if !n or n.type == 'tag'
    n

tagprev = (n) ->
    loop
        n = n.prev
        break if !n or n.type == 'tag'
    n

module.exports =

    find: do ->
        walk = (nodes, fn) ->
            for n in nodes when n.type == 'tag'
                fn n
                walk n.children, fn if n.children
            null
        exec walk, null, true

    closest: do ->
        up = (n, fn) ->
            ret = fn n
            up(n.parent, fn) if n.parent and not ret
            null
        walkup = (nodes, fn) ->
            up(n, fn) for n in nodes
            null
        exec walkup, uniq, true

    parent: do ->
        up = (nodes, fn) ->
            fn n.parent for n in nodes when n.parent
            null
        exec up, uniq

    parents: do ->
        up = (n, fn) ->
            ret = fn n
            up(n.parent, fn) if n.parent
            null
        walkup = (nodes, fn) ->
            up(n.parent, fn) for n in nodes when n.parent
            null
        exec walkup, uniq

    next: do ->
        right = (nodes, fn) ->
            fn p for n in nodes when p = tagnext(n)
            null
        exec right, null

    nextAll: do ->
        right = (n, fn) -> if p = tagnext(n)
            fn p; right p, fn
        walkright = (nodes, fn) ->
            right(n, fn) for n in nodes
            null
        exec walkright, null

    prev: do ->
        left = (nodes, fn) ->
            fn p for n in nodes when p = tagprev(n)
            null
        exec left, null

    prevAll: do ->
        left  = (n, fn) -> if p = tagprev(n)
            fn p; left p, fn
        walkleft = (nodes, fn) ->
            left(n, fn) for n in nodes
            null
        exec walkleft, null

    siblings: do ->
        left  = (n, fn) -> if p = tagprev(n)
            fn p; left p, fn
        right = (n, fn) -> if p = tagnext(n)
            fn p; right p, fn
        walk = (nodes, fn) ->
            for n in nodes
                left n, fn
                right n, fn
            null
        exec walk, null

    children: do ->
        down = (nodes, fn) -> for n in nodes when n.children
            fn cn for cn in n.children when cn.type == 'tag'
        exec down, null

    filter: do ->
        walk = (nodes, fn) ->
            fn n for n in nodes when n.type == 'tag'
        exec walk, null

    is: (roots, exp) -> !!@filter(roots, exp).length
