{split, mixin, merge} = require 'fnuc'
lexer = require './lexer'
spc = split ' '

prec   = (pr) -> (fn) -> fn.pr = pr; fn
precof = (fn) -> fn?.pr ? 0

tagexp = (type, pr, npr) -> prec(pr) (parse, token) ->
    ntoken = parse.peek()
    prx = PREFIX2[ntoken?.type]
    right = (parse.consume(); prx parse, ntoken) if npr < precof(prx)
    mixin {type, token, right}

sel_id     = tagexp 'id',     2, 2
sel_class  = tagexp 'class',  2, 2
sel_pseudo = tagexp 'pseudo', 2, 2
sel_word   = tagexp 'word',   3, 1

# get a quoted or unquoted string
string = (parse) ->
    token = parse.peek()
    if token.type == 'quote'
        parse.consume()
        word = parse.expect(/((?!")[^\\]|\\.)*/g) # anything but quote
        throw new Error "Expected quoted string #{parse.pos()}: #{parse.s}" unless word
        end = parse.expect('quote')
        word
    else if token.type == 'word'
        parse.consume()
        token
    else
        throw new Error "Expected quote or word #{parse.pos()}: #{parse.s}"

sel_attrib = prec(2) (parse, token) ->
    attr = string(parse).word
    token = parse.peek()
    attrtype = ATTR_TYPES[token.type]? parse
    throw new Error "Parse failed at col #{parse.pos()}: #{parse.s}" unless attrtype
    attrval = if attrtype == 'exists' then null else string(parse).word
    parse.expect('clbrack')
    {type:'attrib', token, attrtype, attr, attrval}

ATTR_TYPES = do ->
    symb2 = (type) -> (parse) -> parse.consume(); parse.expect('equals'); type
    clbrack:  (parse) -> 'exists'
    equals:   (parse) -> parse.consume(); 'equals'
    tilde:    symb2 'white'
    pipe:     symb2 'hyphen'
    caret:    symb2 'begin'
    dollar:   symb2 'end'
    asterisk: symb2 'substr'

PREFIX =
    hash:  sel_id
    dot:   sel_class
    colon: sel_pseudo
    word:  sel_word

PREFIX2 = mixin PREFIX,
    opbrack: sel_attrib

infixop  = (type, pr) -> prec(pr) (parse, token, left) ->
    {type, token, left, right:parse(pr), deep:true}

INFIX =
    gt:    infixop 'child',   4
    space: infixop 'descend', 4

parser = (s) ->

    # no string? no parse
    return (-> null) unless s

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
        token = peek(true)

        # no more tokens?
        return null unless token

        # next prefix
        if prx = PREFIX[token.type]
            # consume prefix
            consume(true)
        else if token.type == 'gt'
            # special case with leading '>'. reset token to not parse
            # left expression, however token should be parsed as infix
            # with empty left.
            token = null
        else
            throw new Error "Parse failed at col #{pos()}: #{s}"

        # left expression
        left = prx parse, token if token

        # may return infix expression or left
        parseInfix pr, left, true


    # expose lexer functions
    merge parse, lex, {s}

    parse


module.exports = parser
