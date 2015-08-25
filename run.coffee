
parser = require './src/parser'

test = '.a.b > '

parse = parser(test)

strfy = (o) -> JSON.stringify o, null, '  '

while tok = parse.consume()
    console.log tok

console.log ''

parse = parser(test)

while op = parse()
    console.log strfy op
