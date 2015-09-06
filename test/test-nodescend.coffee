
zu = require '../src/zu'

html = '''
<div id="a" class="a b">
  <b>panda11</b>
  <span class="c">
    <i>panda2</i>
    <span class="d">panda3</span>
  </span>
</div>'''

ns = zu.parseHtml html

describe 'no descend', ->

    it 'is ok with nothing', ->
        eql zu.find(ns), []

    it 'works for only class', ->
        eql zu.find(ns, '.c'), ['<span.c>']

    it 'selects none', ->
        eql zu.find(ns, 'p'), []

    it 'selects top level', ->
        eql zu.find(ns, 'div'), ['<div#a.a.b>']

    it 'selects one level down', ->
        eql zu.find(ns, 'b'), ['<b>']

    it 'selects two levels down', ->
        eql zu.find(ns, 'i'), ['<i>']

    it 'selects multiple levels', ->
        eql zu.find(ns, 'span'), ['<span.c>','<span.d>']

describe 'findWith', ->

    it 'works for expression first', ->
        eql zu.findWith('.c')(ns), ['<span.c>']

    it 'works for nodes first', ->
        eql zu.findWith(ns)('.c'), ['<span.c>']

    it 'works for node without array first', ->
        eql zu.findWith(ns[0])('.c'), ['<span.c>']
