
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

describe 'descend', ->

    describe 'single', ->

        it 'selects none', ->
            eql z.find('div p'), []

        it 'selects one level down', ->
            eql z.find('div b'), ['<b>']

        it 'selects two levels down', ->
            eql z.find('div i'), ['<i>', '<i>']

        it 'selects multiple levels', ->
            eql z.find('div span'), ['<span.c>','<span.d>','<span.g>','<span.h>']

    describe 'multiple', ->

        it 'selects none', ->
            eql z.find('div div p'), []

        it 'selects two levels down', ->
            eql z.find('div div i'), ['<i>']

        it 'selects multiple levels', ->
            eql z.find('div div span'), ['<span.g>','<span.h>']

    describe 'multiple apart', ->

        it 'selects', ->
            eql z.find('div#a span.g em'), ['<em>']
