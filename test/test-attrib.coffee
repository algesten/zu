
zu = require '../src/zu'

html = '''
<div class="hello-example">
    <a class="a1" href="http://example.com">English:</a>
    <span class="s1" lang="en-us en-gb en-au en-nz">Hello World!</span>
</div>
<div class="hello-example">
    <a class="a2" href="#portuguese">Portuguese:</a>
    <span class="s2" lang="pt">Olá Mundo!</span>
</div>
<div class="hello-example">
    <a class="a3" href="http://example.cn">Chinese (Simplified):</a>
    <span class="s3" lang="zh-CN">世界您好！</span>
</div>
<div class="hello-example">
    <a class="a4" href="http://example.cn">Chinese (Traditional):</a>
    <span class="s4" lang="zh-TW">世界您好！</span>
    <span foo="" class="s5">Not lang</span>
</div>
'''

z = zu(html)

describe 'attrib', ->

    it 'selects just span[lang]', ->
        eql z.find('span[lang]'), ['<span.s1>', '<span.s2>', '<span.s3>', '<span.s4>']

    it 'selects span[lang="pt"]', ->
        eql z.find('span[lang=pt]'), ['<span.s2>']

    it 'selects span[lang=pt]', ->
        eql z.find('span[lang=pt]'), ['<span.s2>']

    it 'selects span[foo=""]', ->
        eql z.find('span[foo=""]'), ['<span.s5>']

    it 'selects span[lang~=en-us]', ->
        eql z.find('span[lang~=en-us]'), ['<span.s1>']

    it 'selects span[lang|=zh]', ->
        eql z.find('span[lang|=zh]'), ['<span.s3>', '<span.s4>']

    it 'selects a[href^="#"]', ->
        eql z.find('a[href^="#"]'), ['<a.a2>']

    it 'selects a[href$=".cn"]', ->
        eql z.find('a[href$=".cn"]'), ['<a.a3>', '<a.a4>']

    it 'selects a[href*="example"]', ->
        eql z.find('a[href*="example"]'), ['<a.a1>','<a.a3>','<a.a4>']
