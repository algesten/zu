
zu = require '../src/zu'

html = '''
<div id="a" class="a b">
  <b>panda11</b>
  <span class="c">
    <i>panda2</i>
    <span class="d">panda3</span>
  </span>
</div>'''

z = zu(html)

describe 'no descend', ->

    it 'is ok with nothing', ->
        eql z.find(), []

    it 'selects none', ->
        eql z.find('p'), []

    it 'selects top level', ->
        eql z.find('div'), ['<div#a.a.b>']

    it 'selects one level down', ->
        eql z.find('b'), ['<b>']

    it 'selects two levels down', ->
        eql z.find('i'), ['<i>']

    it 'selects multiple levels', ->
        eql z.find('span'), ['<span.c>','<span.d>']
