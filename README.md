zu
==

> aus außer bei mit nach seit von *zu*

Minimal DOM grokking with CSS style selectors

Motivation
----------

When reading XML/markup data on the server, I often reach for a
jQuery-esque tool using CSS selectors to extract various bits of the
document. There are [solutions][1] solving that problem already,
however jQuery is an acquired taste, and with my latest foragings into
[functional programming][2], those API:s just feel awkward.

### Installing with NPM

```bash
npm install -S zu
```

Use in a project

```javascript
var zu = require('zu');

var nodes = zu.parse(<some xml string>);
var subs  = zu.find(nodes, 'div#a > span.b');
```

### Goals

* Composable [curried][4] functions, not methods.

* Selectors returns `Array`s, not "array-like objects". This means
  functional libraries such as [fnuc][2] and [Ramda][3] can
  interoperate.

* Reading, not manipulating. This cuts out a lot of code as well as
  avoids awkward jQuery style dual-purpose functions (get/set).

* Performance. Especially matching should be fast.

* XML bias. HTML is the odd one out.

### Curry

Two argument functions are curried. For all [selectors](#selectors)
the curry takes these forms (illustrated by `children`, but applicable
to all selectors).

##### Both arguments

```coffee
zu.children(nodes, selector)
```

##### Binding a selector

```javascript
var sel  = zu.children(expr);   // sel is a function operating on node
var subs = sel(nodes)           // apply sel on nodes to get some children
```

##### No selector

This form may be surprising for functional purists. It's a compromise
to allow use of the selection functions without a "filtering"
selection expression.

```javascript
var subs = zu.children(nodes);      // no selector, just get all children
```

TODO: Can we make this work for partial application of nodes?
I.e. `zu.find(nodes)`

TODO: Argument order is opposite that of Ramda. Do we need a reverse
argument version of zu? I.e. `var zu = require('zu/reverse');`

### Parsing

    parse:     (a) -> domparser.xml a
    parseHtml: (a) -> domparser.html a


    xml:       (ns) -> domparser.renderXml ns
    html:      (ns) -> domparser.renderHtml ns
    text:      (ns) -> domparser.renderText ns

        attr:      (ns, name) -> ns[0]?.attribs?[name]
        hasClass:  (ns, name) -> return true for n in ns when hasclass(n, name); return false

### Selectors

        find:      (ns, sel) -> selectors.find     ns, sel
        closest:   (ns, sel) -> selectors.closest  ns, sel
        parent:    (ns, sel) -> selectors.parent   ns, sel
        parents:   (ns, sel) -> selectors.parents  ns, sel
        next:      (ns, sel) -> selectors.next     ns, sel
        nextAll:   (ns, sel) -> selectors.nextAll  ns, sel
        prev:      (ns, sel) -> selectors.prev     ns, sel
        prevAll:   (ns, sel) -> selectors.prevAll  ns, sel
        siblings:  (ns, sel) -> selectors.siblings ns, sel
        children:  (ns, sel) -> selectors.children ns, sel
        filter:    (ns, sel) -> selectors.filter   ns, sel
        is:        (ns, sel) -> selectors.is       ns, sel

[1]: https://github.com/cheeriojs/cheerio "Cheerio"
[2]: https://github.com/algesten/fnuc     "fnuc"
[3]: https://github.com/ramda/ramda       "Ramda"
[4]: https://en.wikipedia.org/wiki/Currying "Curry"
