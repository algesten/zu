{split, merge} = require 'fnuc'
lexer = require './lexer'
spc = split ' '

NOT_QUOTE = /((?!")[^\\]|\\.)*/g           # anything but quote
NOT_ATTRIB = /((?![\]=~|^$*])[^\\]|\\.)*/g # anything but ]=~|^$*
NOT_CLBRACK = /((?!])[^\\]|\\.)*/g         # anything but close bracket
NOT_CLPAREN = /((?!\))[^\\]|\\.)*/g        # anything but close paren

# get a quoted string or something matching given re
quotedor = (parse, re) ->
    token = parse.peek()
    if token.type == 'quote'
        parse.consume()
        word = parse.expect(NOT_QUOTE)
        end = parse.expect('quote')
        word
    else
        parse.expect(re)

continueright = (parse) ->
    token = parse.peek()
    prx = PREFIX2[token?.type]
    if prx
        parse.consume()
        prx parse, token

tagexp = (type) -> (parse, token) ->
    word = parse.expect('word').word
    right = continueright parse
    {type, token, word, right}

sel_id     = tagexp 'id'
sel_class  = tagexp 'class'
sel_word   = (parse, token) ->
    ntoken = parse.peek()
    if ntoken and (ntoken.type == 'colon' or (ispipe = ntoken.type == 'pipe'))
        ntoken2 = parse.peek(false, ntoken.len)
        if ntoken2?.type == 'word' and (ispipe or not PSEUDO[ntoken2.word])
            parse.consume(); parse.consume()
            token.word = token.word + ":" + ntoken2.word
            token.len = token.word.length
    right = continueright parse
    {type:'word', token, right}
sel_all    = (parse, token) ->
    right = continueright parse
    {type:'all', token, right}

sel_attrib = (parse, token) ->
    attr = quotedor(parse, NOT_ATTRIB).word
    ntoken = parse.peek()
    attrtype = ATTR_TYPES[ntoken.type]? parse
    throw new Error "Parse failed at col #{parse.pos()}: #{parse.s}" unless attrtype
    attrval = if attrtype == 'exists' then null else quotedor(parse, NOT_CLBRACK).word
    parse.expect('clbrack')
    right = continueright parse
    {type:'attrib', token, attrtype, attr, attrval, right}

ATTR_TYPES = do ->
    symb2 = (type) -> (parse) -> parse.consume(); parse.expect('equals'); type
    clbrack:  (parse) -> 'exists'
    equals:   (parse) -> parse.consume(); 'equals'
    tilde:    symb2 'white'
    pipe:     symb2 'hyphen'
    caret:    symb2 'begin'
    dollar:   symb2 'end'
    asterisk: symb2 'substr'

sel_pseudo = (parse, token) ->
    ntoken = parse.consume()
    pseudotype = ntoken.word
    pfn = PSEUDO[pseudotype]
    throw new Error "Parse failed at col #{parse.pos()}: #{parse.s}" unless pfn
    pseudoval = pfn(parse)
    right = continueright parse
    {type:'pseudo', token, pseudotype, pseudoval, right}

PSEUDO =
    'contains': (parse) ->
        parse.expect('opparen')
        val = quotedor(parse, NOT_CLPAREN).word
        parse.expect('clparen')
        val
    'empty':       ->
    'first-child': ->
    'last-child':  ->

PREFIX =
    hash:     sel_id
    dot:      sel_class
    word:     sel_word
    asterisk: sel_all

PREFIX2 =
    hash:     sel_id
    dot:      sel_class
    colon:    sel_pseudo
    opbrack:  sel_attrib

infixop  = (type) -> (parse, token, left) ->
    {type, token, left, right:parse(false), deep:true}

INFIX =
    gt:    infixop 'child'
    space: infixop 'descend'

parser = (s) ->

    # no string? no parse
    return (-> null) unless s

    # lexer functions
    lex = lexer(s)
    {peek, consume, expect, pos} = lex

    # infix operator parsing
    parseInfix = (left, skipsp) ->

        # peek at next token
        token = peek(skipsp)

        # infix for peek token
        ifx = INFIX[token?.type]

        # no infix operator for next token
        unless ifx
            # did we skip space and there was a token?
            if skipsp and token
                # then we consider the space a token, redo
                # the parseInfi and do not skip space.
                return parseInfix left, false
            else
                return left
        else
            # this is the new left expression
            consume(skipsp) # actually consume it
            parseInfix ifx(parse, token, left), true

    # parser function
    parse = (doinfix = true) ->

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

        if doinfix
            # may return infix expression or left
            parseInfix left, true
        else
            left


    # expose lexer functions
    merge parse, lex, {s}

    parse


module.exports = parser
