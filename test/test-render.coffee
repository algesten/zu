
zu = require '../src/zu'

html = '''
<div id="a" class="a b">
    1 <img src="foo.jpg"/>
    <span>foo</span> 2
</div>
'''

ns = zu.parseHtml html

describe 'xml', ->

    it 'renders output as xml', ->
        assert.equal zu.xml(ns), '<div id="a" class="a b">\n    '+
        '1 <img src="foo.jpg"/>\n    <span>foo</span> 2\n</div>'  # <img is closing

    it 'works for subtree', ->
        assert.equal zu.xml(zu.find(ns,'img')), '<img src="foo.jpg"/>'

describe 'html', ->

    it 'renders output as html', ->
        assert.equal zu.html(ns), '<div id="a" class="a b">\n    '+
        '1 <img src="foo.jpg">\n    <span>foo</span> 2\n</div>'  # <img is not closing

    it 'works for subtree', ->
        assert.equal zu.html(zu.find(ns, 'img')), '<img src="foo.jpg">'

describe 'text', ->

    it 'renders output as text', ->
        assert.equal zu.text(ns), '\n    1 foo 2\n'
        assert.equal zu.text(zu.find(ns, 'span')), 'foo'

    it 'accepts non-arrays', ->
        assert.equal zu.text(zu.find(ns, 'span')[0]), 'foo'

    it 'accepts undefined', ->
        assert.equal zu.text(undefined), ''
