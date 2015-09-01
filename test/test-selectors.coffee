
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

describe 'closest', ->

    it 'selects nothing for nothing', ->
        eql z.find('i').closest(), []

    it 'selects self', ->
        eql z.find('i').closest('i'), ['<i>', '<i>']

    it 'selects parent', ->
        eql z.find('i').closest('div'), ['<div#a.a.b>', '<div#b.e.f>']

    it 'dedupes parent', ->
        eql z.find('i').closest('div#a'), ['<div#a.a.b>']

describe 'parent', ->

    it 'selects immediate parent', ->
        eql z.find('i').parent(), ['<span.c>', '<span.g>']

    it 'qualified using selector', ->
        eql z.find('i').parent('div#b > span'), ['<span.g>']

describe 'next', ->

    it 'selects the next sibling', ->
        eql z.find('i').next(), ['<span.d>', '<span.h>']

    it 'selects none if no next sibling', ->
        eql z.find('div#b').next(), []

    it 'qualifies using a selector', ->
        eql z.find('i').next('.d'), ['<span.d>']

describe 'prev', ->

    it 'selects the previous sibling', ->
        eql z.find('i').next().prev(), ['<i>', '<i>']

    it 'selects none if no previous sibling', ->
        eql z.find('i').prev(), []

    it 'qualifies using a selector', ->
        eql z.find('span').prev('b'), ['<b>']

describe 'siblings', ->

    it 'selects siblings both right/left', ->
        eql z.find('.c').siblings(), ['<b>','<div#b.e.f>']

    it 'selects no if there are none', ->
        eql z.find('#a').siblings(), []

    it 'qualified with a selector', ->
        eql z.find('.c').siblings('b'), ['<b>']

describe 'children', ->

    it 'selects the children', ->
        eql z.find('span').children(), ['<i>', '<span.d>', '<i>', '<span.h>', '<em>']

    it 'selects none unless children', ->
        eql z.find('em').children(), []

    it 'qualifies with a selector', ->
        eql z.find('span').children('span'), ['<span.d>', '<span.h>' ]
