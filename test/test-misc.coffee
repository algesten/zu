
zu = require '../src/zu'

html = '''
<div id="a" class="a b">
    <img           src="foo1.jpg"/>
    <img class="c" src="foo2.jpg"/>
    <img           src="foo3.jpg"/>
    <img class="d" src="foo4.jpg"/>
</div>
'''

z = zu(html)

describe 'attr', ->

    it 'extracts the attribute value of the first selected node', ->
        assert.equal z.find('img').attr('src'), 'foo1.jpg'

    it 'returns undefined if first node is missing the attribute', ->
        assert.equal z.find('img').attr('class'), undefined

describe 'hasClass', ->

    it 'checks whether any of the matched elements has the class', ->
        assert.equal z.find('img').hasClass('c'), true
        assert.equal z.find('img').hasClass('d'), true

    it 'returns false if none has the class', ->
        assert.equal z.find('img').hasClass('nosuchclass'), false
