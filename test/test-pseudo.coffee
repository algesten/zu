
zu = require '../src/zu'

html = '''
<div class="hello-example">
    <a class="a1" href="http://example.com">English:</a>
    <span class="s1" lang="en-us en-gb en-au en-nz">Hello World!</span>
</div>
<div class="hello-example">
    <a class="a2" href="#portuguese">Portuguese:</a>
    <span class="s2" lang="pt">Olá Mundo!</span>
    <span class="s2" lang="dk">Another</span>
    <span class="s21" lang="dk"><!-- I am but an empty vessel --></span>
    <span class="s22" lang="dk"> <!-- I am not empty --> </span>
    <span class="s23" lang="dk"><img/></span>
</div>
<div class="hello-example">
    <a class="a3" href="http://example.cn">Chinese (Simplified):</a>
    <span class="s3" lang="zh-CN">世界您好！</span>
</div>
<div class="hello-example">
    <a class="a4" href="http://example.cn">Chinese (Traditional):</a>
    <span class="s4" lang="zh-TW">世_界您好！</span>
    <span foo="" class="s5">Not lang</span>
</div>
'''

ns = zu.parseHtml html

describe 'pseudo-class', ->

    describe ':contains()', ->

        it 'selects elements holding the specified text content', ->
            eql zu.find(ns, 'span:contains(世界您好！)'), ['<span.s3>']

    describe ':empty', ->

        it 'selects nodes with no children', ->
            eql zu.find(ns, 'span:empty'), ['<span.s21>']

    describe ':first-child', ->

        it 'selects nodes that are the first child element of their parent', ->
            eql zu.find(ns, '*:first-child'), ['<a.a1>', '<a.a2>', '<img>', '<a.a3>', '<a.a4>']

    describe ':last-child', ->

        it 'selects nodes that are the last child element of their parent', ->
            eql zu.find(ns, '*:last-child'), ['<span.s1>','<span.s23>',
            '<img>','<span.s3>','<span.s5>']
