{keys} = require 'fnuc'

SYMBOLS =
    '.': 'dot'
    '#': 'hash'
    '>': 'gt'
    ',': 'comma'
    '[': 'opbrack'
    ']': 'clbrack'
    '(': 'opparen'
    ')': 'clparen'
    '=': 'equals'
    '~': 'tilde'
    '|': 'pipe'
    '^': 'caret'
    '$': 'dollar'
    '*': 'asterisk'
    '"': 'quote'
    ':': 'colon'

# whitespace is sp
ws = " "

escre = require './escre'

execpos = (re) -> (s, pos) ->
    re.lastIndex = pos
    m = re.exec s
    unless m?.index == pos then 0 else m[0].length

space  = execpos(RegExp "[#{ws}]+", "g")
word   = execpos(RegExp "[^#{ws}#{escre keys(SYMBOLS).join('')}]+", "g")
symbol = (s, pos) -> if r = SYMBOLS[s[pos]] then r else null

lexer = (s) ->

    tok = (start, skipsp) ->
        if start == s.length
            null
        else if len = space s, start
            if skipsp then tok(start + len) else {type:'space', start, len}
        else if len = word s, start
            {type:'word', start, len, word:s[start...(start+len)]}
        else if type = symbol s, start
            {type, start, len:1}
        else
            throw new Error("Unknown input pos: #{start}")

    # current lexer position
    pos = 0

    # peek at next token
    peek = (skipsp, offs=0) -> tok (pos + offs), skipsp

    # consume next token (move position forward)
    consume = (skipsp) ->
        token = tok pos, skipsp
        pos = token.start + token.len if token
        token

    # expect token of given type and consume it
    expect = (type, skipsp) ->
        if type instanceof RegExp
            start = pos
            len = execpos(type)(s, start)
            if len != undefined
                pos = start + len
                token = {token:'re', start:pos, len, word:s[start...(start+len)]}
        else
            token = consume skipsp
            if token?.type != type
                throw new Error "Expected '#{type}' at col #{pos}: #{s}"
        token

    {peek, consume, expect, pos:->pos}

module.exports = lexer
