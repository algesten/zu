{split, mixin, merge} = require 'fnuc'
lexer = require './lexer'
spc = split ' '

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

continueright = (parse, token) ->
    ntoken = parse.peek()
    prx = PREFIX2[ntoken?.type]
    if prx
        parse.consume()
        prx parse, ntoken

tagexp = (type) -> (parse, token) ->
    word = parse.expect('word').word
    right = continueright parse, token
    mixin {type, token, word, right}

sel_id     = tagexp 'id'
sel_class  = tagexp 'class'
sel_pseudo = tagexp 'pseudo'
sel_word   = (parse, token) ->
    right = continueright parse, token
    mixin {type:'word', token, right}


sel_attrib = (parse, token) ->
    attr = string(parse).word
    token = parse.peek()
    attrtype = ATTR_TYPES[token.type]? parse
    throw new Error "Parse failed at col #{parse.pos()}: #{parse.s}" unless attrtype
    attrval = if attrtype == 'exists' then null else string(parse).word
    parse.expect('clbrack')
    right = continueright parse, token
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

PREFIX =
    hash:  sel_id
    dot:   sel_class
    colon: sel_pseudo
    word:  sel_word

PREFIX2 = mixin PREFIX,
    opbrack: sel_attrib

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
