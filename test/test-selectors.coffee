
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
      <p>qwe</p>
    </span>
  </div>
</div>'''

ns = zu.parseHtml html

describe 'closest', ->

    it 'selects nothing for nothing', ->
        eql zu.closest(zu.find(ns,'i')), []

    it 'selects self', ->
        eql zu.closest(zu.find(ns,'i'),'i'), ['<i>', '<i>']

    it 'selects parent', ->
        eql zu.closest(zu.find(ns,'i'),'div'), ['<div#a.a.b>', '<div#b.e.f>']

    it 'dedupes parent', ->
        eql zu.closest(zu.find(ns,'i'),'div#a'), ['<div#a.a.b>']

describe 'parent', ->

    it 'selects immediate parent', ->
        eql zu.parent(zu.find(ns,'i')), ['<span.c>', '<span.g>']

    it 'qualified using selector', ->
        eql zu.parent(zu.find(ns,'i'),'div#b > span'), ['<span.g>']

describe 'parents', ->

    it 'selects all parents', ->
        eql zu.parents(zu.find(ns,'em')), ['<span.h>', '<span.g>', '<div#b.e.f>', '<div#a.a.b>']

    it 'qualifies using selector', ->
        eql zu.parents(zu.find(ns,'em'),'#b'), ['<div#b.e.f>']

describe 'next', ->

    it 'selects the next sibling', ->
        eql zu.next(zu.find(ns,'i')), ['<span.d>', '<span.h>']

    it 'selects none if no next sibling', ->
        eql zu.next(zu.find(ns,'div#b')), []

    it 'qualifies using a selector', ->
        eql zu.next(zu.find(ns,'i'),'.d'), ['<span.d>']

describe 'nextAll', ->

    it 'selects all following siblings', ->
        eql zu.nextAll(zu.find(ns,'.g i')), ['<span.h>', '<p>']

    it 'selects none if no next sibling', ->
        eql zu.nextAll(zu.find(ns,'.g p')), []

    it 'qualifies using a selector', ->
        eql zu.next(zu.find(ns,'i'),'.d'), ['<span.d>']

describe 'prev', ->

    it 'selects the previous sibling', ->
        eql zu.prev(zu.next(zu.find(ns,'i'))), ['<i>', '<i>']

    it 'selects none if no previous sibling', ->
        eql zu.prev(zu.find(ns,'i')), []

    it 'qualifies using a selector', ->
        eql zu.prev(zu.find(ns,'span'),'b'), ['<b>']

describe 'prevAll', ->

    it 'selects all previous siblings', ->
        eql zu.prevAll(zu.find(ns,'.g p')), ['<span.h>','<i>']

    it 'selects none if no previous sibling', ->
        eql zu.prevAll(zu.find(ns,'i')), []

    it 'qualifies using a selector', ->
        eql zu.prevAll(zu.find(ns,'.g p'),'i'), ['<i>']

describe 'siblings', ->

    it 'selects siblings both right/left', ->
        eql zu.siblings(zu.find(ns,'.c')), ['<b>','<div#b.e.f>']

    it 'selects no if there are none', ->
        eql zu.siblings(zu.find(ns,'#a')), []

    it 'qualified with a selector', ->
        eql zu.siblings(zu.find(ns,'.c'),'b'), ['<b>']

describe 'children', ->

    it 'selects the children', ->
        eql zu.children(zu.find(ns,'span')), ['<i>', '<span.d>', '<i>', '<span.h>', '<p>', '<em>']

    it 'selects none unless children', ->
        eql zu.children(zu.find(ns,'em')), []

    it 'qualifies with a selector', ->
        eql zu.children(zu.find(ns,'span'),'span'), ['<span.d>', '<span.h>' ]

describe 'filter', ->

    it 'filters the nodes by a selector', ->
        eql zu.filter(zu.children(ns),'div'), ['<div#b.e.f>']

    it 'doesnt filter if not selector', ->
        eql zu.filter(zu.children(ns), null), ['<b>', '<span.c>', '<div#b.e.f>']

    it 'creates new array for empty selector', ->
        nodes = zu.children(ns)
        nodes2 = zu.filter(nodes)
        assert.notStrictEqual nodes, nodes2

describe 'is', ->

    it 'returns true if any child matches the selector', ->
        assert.equal zu.is(zu.find(ns,'em'), 'em'), true
        assert.equal zu.is(zu.find(ns,'span'), '.d'), true

    it 'returns false if no child matches the selector', ->
        assert.equal zu.is(zu.find(ns,'span'), 'em'), false

    it 'returns true if no expression and given some nodes', ->
        assert.equal zu.is(zu.find(ns, 'span')), true

    it 'returns false if no expression and given empty array', ->
        assert.equal zu.is([]), false
