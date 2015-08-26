{split, mixin, merge} = require 'fnuc'
lexer = require './lexer'
spc = split ' '

prec   = (pr) -> (fn) -> fn.pr = pr; fn
precof = (fn) -> fn?.pr ? 0

infixop  = (type, pr) -> prec(pr) (parse, token, left) -> {type, token, left, right:parse(pr)}

tagexp = (type, pr, npr) -> prec(pr) (parse, token) ->
    ntoken = parse.peek(false)
    prx = PREFIX[ntoken?.type]
    right = (parse.consume(false); prx parse, ntoken) if npr < precof(prx)
    mixin {type, token, right}

sel_id     = tagexp 'id',     2, 2
sel_class  = tagexp 'class',  2, 2
sel_pseudo = tagexp 'pseudo', 2, 2
sel_word   = tagexp 'word',   3, 1

PREFIX =
    hash:  sel_id
    dot:   sel_class
    colon: sel_pseudo
    word:  sel_word

INFIX =
    gt:    infixop 'child',   4
    space: infixop 'descend', 4

parser = (s) ->

    # lexer functions
    lex = lexer(s)
    {peek, consume, expect, pos} = lex

    # infix operator parsing
    parseInfix = (pr, left, skipsp) ->

        # peek at next token
        token = peek(skipsp)

        # infix/precedence for peek token
        ifx = INFIX[token?.type]
        ifxpr = precof ifx

        # no infix operator for next token
        unless ifx
            # did we skip space and there was a token?
            if skipsp and token
                return parseInfix pr, left, false
            else
               return left

        # maybe make it the new left expression
        if pr < ifxpr
            consume(skipsp) # actually consume it
            parseInfix pr, ifx(parse, token, left), true
        else
            left

    # parser function with precedence
    parse = (pr = 0) ->

        # next token
        token = consume(true)

        # no more tokens?
        return null unless token

        # next prefix
        unless prx = PREFIX[token.type]
            throw new Error "Parse failed at col #{pos()}: #{s}"

        # left expression
        left = prx parse, token

        # may return infix expression or left
        parseInfix pr, left, true


    # expose lexer functions
    merge parse, lex

    parse


module.exports = parser
