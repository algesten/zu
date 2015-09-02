{I, uniq}  = require 'fnuc'
matcher = require './matcher'
parser  = require './parser'
{evl}   = matcher

# when collecting nodes we do tests against the lowest
# level in a selector expressions. this forms a starting
# point for executing the entire ast using the matcher.
collector = (ast) ->
    nodes = []
    # ast.deep means a child/descend expression
    lst = if ast?.deep then ast.right else ast
    coll = (n) -> nodes.push n if evl(n, lst)
    {nodes, coll}

parse = (sel) -> parser(sel)()

exec = (walk, pre, emptyast) -> (roots, sel) ->
    ast = parse sel
    return [] if emptyast and !ast
    {nodes, coll} = collector ast
    walk roots, coll
    matcher roots, pre(nodes), ast

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
            for n in nodes
                fn n
                walk n.children, fn if n.children
            null
        exec walk, I, true

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
        exec right, I

    nextAll: do ->
        right = (n, fn) ->
            ret = fn n if n.type == 'tag'
            right(n.next, fn) if n.next
            null
        walkright = (nodes, fn) ->
            right(n.next, fn) for n in nodes when n.next
            null
        exec walkright, I

    prev: do ->
        left = (nodes, fn) ->
            fn p for n in nodes when p = tagprev(n)
            null
        exec left, I

    prevAll: do ->
        left = (n, fn) ->
            ret = fn n if n.type == 'tag'
            left(n.prev, fn) if n.prev
            null
        walkleft = (nodes, fn) ->
            left(n.prev, fn) for n in nodes when n.prev
            null
        exec walkleft, I

    siblings: do ->
        left  = (n, fn) ->
            if p = tagprev(n)
                fn p
                left p
        right = (n, fn) ->
            if p = tagnext(n)
                fn p
                right p
        walk = (nodes, fn) ->
            for n in nodes
                left n, fn
                right n, fn
            null
        exec walk, I

    children: do ->
        down = (nodes, fn) -> for n in nodes when n.children
            fn cn for cn in n.children when cn.type == 'tag'
        exec down, I

    is: do ->
        walk = (nodes, fn) ->
            fn n for n in nodes
        (roots, sel) ->
            ast = parse sel
            {nodes, coll} = collector ast
            walk roots, coll
            !!matcher(roots, nodes, ast).length
