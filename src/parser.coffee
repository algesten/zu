{split, mixin} = require 'fnuc'
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

    # current parse position
    pos = 0

    # function returning token at position
    # token(pos, skipsp)
    lex = lexer(s)

    # peek at next token
    peek = (skipsp) -> lex pos, skipsp

    # consume next token and return it
    consume = (skipsp) ->
        token = lex pos, skipsp
        pos = token.start + token.len if token
        token

    # expect token of given type and consume it
    expect = (type) ->
        token = consume(false)
        if token?.type != type
            throw new Error "Expected '#{type}' at col #{pos}: #{s[pos..(pos + 10)]}"
        token

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
            throw new Error "Parse failed at col #{token.start}: #{s[pos..(pos + 10)]}"

        # left expression
        left = prx parse, token

        # may return infix expression or left
        parseInfix pr, left, true


    # expose consume/peek/expect
    parse.consume = consume
    parse.peek    = peek
    parse.expect  = expect

    parse




module.exports = parser
