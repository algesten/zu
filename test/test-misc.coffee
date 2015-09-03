
zu = require '../src/zu'

html = '''
<div id="a" class="a b">
    <img           src="foo1.jpg"/>
    <img class="c" src="foo2.jpg"/>
    <img           src="foo3.jpg"/>
    <img class="d" src="foo4.jpg"/>
</div>
'''

ns = zu.parseHtml html

describe 'attr', ->

    it 'extracts the attribute value of the first selected node', ->
        assert.equal zu.attr(zu.find(ns,'img'),'src'), 'foo1.jpg'

    it 'returns undefined if first node is missing the attribute', ->
        assert.equal zu.attr(zu.find(ns,'img'),'class'), undefined

describe 'hasClass', ->

    it 'checks whether any of the matched elements has the class', ->
        assert.equal zu.hasClass(zu.find(ns,'img'),'c'), true
        assert.equal zu.hasClass(zu.find(ns,'img'),'d'), true

    it 'returns false if none has the class', ->
        assert.equal zu.hasClass(zu.find(ns,'img'),'nosuchclass'), false
