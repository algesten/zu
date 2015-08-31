{uniq}  = require 'fnuc'
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

module.exports =

    find: do ->
        walk = (nodes, fn) ->
            for n in nodes
                fn n
                walk n.children, fn if n.children
            null
        (roots, sel) ->
            ast = parse sel
            return [] unless ast # special case
            {nodes, coll} = collector ast
            walk roots, coll
            matcher roots, nodes, ast

    parent: do ->
        up = (nodes, fn) ->
            fn n.parent for n in nodes when n.parent
            null
        (roots, sel) ->
            ast = parse sel
            {nodes, coll} = collector ast
            up roots, coll
            matcher roots, uniq(nodes), ast

    closest: do ->
        up = (n, fn) ->
            ret = fn n
            up(n.parent, fn) if n.parent and not ret
            null
        walkup = (nodes, fn) ->
            up(n, fn) for n in nodes
            null
        (roots, sel) ->
            ast = parse sel
            return [] unless ast # special case
            {nodes, coll} = collector ast
            walkup roots, coll
            matcher roots, uniq(nodes), ast
