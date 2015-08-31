
zu = require '../src/zu'

html = '''
<div id="a" class="a b">
    <img src="foo.jpg"/>
    <span>foo</span>
</div>
'''

z = zu(html)

describe 'xml', ->

    it 'renders output as xml', ->
        assert.equal z.xml(), '<div id="a" class="a b">\n    '+
        '<img src="foo.jpg"/>\n    <span>foo</span>\n</div>'  # <img is closing

    it 'works for subtree', ->
        assert.equal z.find('img').xml(), '<img src="foo.jpg"/>'

describe 'html', ->

    it 'renders output as html', ->
        assert.equal z.html(), '<div id="a" class="a b">\n    '+
        '<img src="foo.jpg">\n    <span>foo</span>\n</div>'  # <img is not closing

    it 'works for subtree', ->
        assert.equal z.find('img').html(), '<img src="foo.jpg">'
