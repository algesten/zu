
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

ns = zu.parse html

describe 'child', ->

    describe 'single', ->

        it 'selects none', ->
            eql zu.find(ns, 'div > p'), []

        it 'selects one level down', ->
            eql zu.find(ns, 'div > b'), ['<b>']

        it 'does not select two levels down', ->
            eql zu.find(ns, 'div > i'), []

        it 'selects multiple levels', ->
            eql zu.find(ns, 'div > span.c'), ['<span.c>']

    describe 'multiple', ->

        it 'selects none', ->
            eql zu.find(ns, 'div > div > p'), []

        it 'selects two levels down', ->
            eql zu.find(ns, 'div > div > span > i'), ['<i>']

        it 'selects multiple levels', ->
            eql zu.find(ns, 'div > div > span'), ['<span.g>']

        it 'selects at different depths', ->
            eql zu.find(ns, 'div > span'), ['<span.c>', '<span.g>']

    describe 'immediate', ->

        it 'selects none', ->
            eql zu.find(ns, '> p'), []

        it 'selects immediate descendant of root', ->
            eql zu.find(ns, '> span'), ['<span.c>']

        it 'selects further descendant of root', ->
            eql zu.find(ns, '> span.c i'), ['<i>']
