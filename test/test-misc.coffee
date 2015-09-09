
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

    it 'accepts non arrays', ->
        assert.equal zu.attr(zu.find(ns,'img')[0],'src'), 'foo1.jpg'

    it 'optionally filters using expression', ->
        assert.equal zu.attr(ns, 'img', 'src'), 'foo1.jpg'

    it 'optionally filters using expression in With-version', ->
        assert.equal zu.attrWith(ns, 'img')('src'), 'foo1.jpg'
        assert.equal zu.attrWith('src')(ns, 'img'), 'foo1.jpg'


describe 'hasClass', ->

    it 'checks whether any of the matched elements has the class', ->
        assert.equal zu.hasClass(zu.find(ns,'img'),'c'), true
        assert.equal zu.hasClass(zu.find(ns,'img'),'d'), true

    it 'returns false if none has the class', ->
        assert.equal zu.hasClass(zu.find(ns,'img'),'nosuchclass'), false

    it 'optionally filters using expression', ->
        assert.equal zu.hasClass(ns, 'img', 'c'), true

    it 'optionally filters using expression in With-version', ->
        assert.equal zu.hasClassWith(ns, 'img')('c'), true
        assert.equal zu.hasClassWith('c')(ns, 'img'), true


describe 'namespaces', ->

    xml = '<c:foo>qwe<b:bar>panda</b:bar><d:empty>blah</d:empty></c:foo>'
    ns2 = zu.parseXml xml

    it 'serializes normally', ->
        assert.equal zu.xml(ns2),
        '<c:foo>qwe<b:bar>panda</b:bar><d:empty>blah</d:empty></c:foo>'

    it 'just parses as regular nodes', ->
        eql zu.find(ns2, 'b:bar'), ['<b:bar>']

    it 'will however not work for nodes named like pseudo classes', ->
        eql zu.find(ns2, 'd:empty'), []

    it 'also works with official css namespace b|bar', ->
        eql zu.find(ns2, 'b|bar'), ['<b:bar>']

    it 'the official css namespace works nodes named like pseudo classes', ->
        eql zu.find(ns2, 'd|empty'), ['<d:empty>']
