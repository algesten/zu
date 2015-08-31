
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

z = zu(html)

describe 'parent', ->

    it 'selects immediate parent', ->
        eql z.find('i').parent(), ['<span.c>', '<span.g>']

    it 'qualified using selector', ->
        eql z.find('i').parent('div#b > span'), ['<span.g>']

describe 'closest', ->

    it 'selects nothing for nothing', ->
        eql z.find('i').closest(), []

    it 'selects self', ->
        eql z.find('i').closest('i'), ['<i>', '<i>']

    it 'selects parent', ->
        eql z.find('i').closest('div'), ['<div#a.a.b>', '<div#b.e.f>']

    it 'dedupes parent', ->
        eql z.find('i').closest('div#a'), ['<div#a.a.b>']
