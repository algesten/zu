
zu = require '../src/zu'

html = '''
<div id="a" class="a b">
  <b>panda11</b>
  <span class="c">
    <i>panda2</i>
    <span class="d">panda3</span>
  </span>
  <div id="b" class="e f">
    <span class="g">
      <i>panda4</i>
      <span class="h"><em>panda5</em></span>
    </span>
  </div>
</div>'
'''

z = zu(html)

describe 'child', ->

    describe 'single', ->

        it 'selects none', ->
            eql z.find('div > p'), []

        it 'selects one level down', ->
            eql z.find('div > b'), ['<b>']

        it 'does not select two levels down', ->
            eql z.find('div > i'), []

        it 'selects multiple levels', ->
            eql z.find('div > span.c'), ['<span.c>']

    describe 'multiple', ->

        it 'selects none', ->
            eql z.find('div > div > p'), []

        it 'selects two levels down', ->
            eql z.find('div > div > span > i'), ['<i>']

        it 'selects multiple levels', ->
            eql z.find('div > div > span'), ['<span.g>']

        it 'selects at different depths', ->
            eql z.find('div > span'), ['<span.c>', '<span.g>']

    describe 'immediate', ->

        it 'selects none', ->
            eql z.find('> p'), []

        it 'selects immediate descendant of root', ->
            eql z.find('> span'), ['<span.c>']

        it 'selects further descendant of root', ->
            eql z.find('> span.c i'), ['<i>']
