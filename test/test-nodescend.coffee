
zu = require '../src/zu'

html = '''
<div id="a" class="a b">
  <b>panda11</b>
  <span class="c">
    <i>panda2</i>
    <span class="d">panda3</span>
  </span>
</div>'''

ns = zu.parse html

describe 'no descend', ->

    it 'is ok with nothing', ->
        eql zu.find(ns, null), []

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
