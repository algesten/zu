
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
</div>'''

ns = zu.parseHtml html

describe 'descend', ->

    describe 'single', ->

        it 'selects none', ->
            eql zu.find(ns, 'div p'), []

        it 'selects one level down', ->
            eql zu.find(ns, 'div b'), ['<b>']

        it 'selects two levels down', ->
            eql zu.find(ns, 'div i'), ['<i>', '<i>']

        it 'selects multiple levels', ->
            eql zu.find(ns, 'div span'), ['<span.c>','<span.d>','<span.g>','<span.h>']

    describe 'multiple', ->

        it 'selects none', ->
            eql zu.find(ns, 'div div p'), []

        it 'selects two levels down', ->
            eql zu.find(ns, 'div div i'), ['<i>']

        it 'selects multiple levels', ->
            eql zu.find(ns, 'div div span'), ['<span.g>','<span.h>']

    describe 'multiple apart', ->

        it 'selects', ->
            eql zu.find(ns, 'div#a span.g em'), ['<em>']

    describe 'same selector many levels', ->

        it 'selects correct', ->
            xml = '
            <div class="a">
                <span class="s1"></span>
                <div class="a">
                    <span class="s2"></span>
                </div>
            </div>'
            ns2 = zu.parseXml xml
            eql zu.find(ns2, '.a .a span'), ['<span.s2>']
