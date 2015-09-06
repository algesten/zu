zu
==

Functional DOM grokking with CSS style selectors

[![Build Status](https://travis-ci.org/algesten/zu.svg)](https://travis-ci.org/algesten/zu)

> aus außer bei mit nach seit von *zu*

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

* Selectors return `Array`s, not "array-like objects". This means
  functional libraries such as [fnuc][2] and [Ramda][3] can
  interoperate.

* Reading, not manipulating. This cuts out a lot of code as well as
  avoids awkward jQuery style dual-purpose functions (get/set).

* Performance. Especially matching should be fast.

* XML bias. HTML is the odd one out. Namespaces do not need escaping
  in selector expressions (`zu.find(nodes, 'e:event')`).

## Curry

Each `zu.[something](n,e)` that takes two arguments also have two
curried version `zu.[something]With(n)` and `zu.[something]With(e)`
Example illustrated with `zu.parent`.

##### Both arguments

* `:: ns, s -> ns`

No curry here.

```javascript
zu.parent(nodes, exp);
```

##### One argument

* `:: ns -> ns`

Equivalent to having `null` as second argument.

```javascript
zu.parent(nodes);
```

##### Partially applied nodes

* `:: ns -> s -> ns`

Provided an array, gives a function expecting the expression.

```javascript
zu.parentWith(nodes);
```

##### Partially applied with expression

* `:: s -> ns -> ns`

Provided an expression, gives a function expecting an array.

```javascript
zu.parentWith(exp);
```


## CSS Selectors

The following selectors are (currently) supported:

* Type selector `div`
* All selector `*`
* Descendant `div span`
* Child `div > span`. Also works as `> span` for immediate children.
* Class `div.foo`
* Id `div#bar`
* Namespace `e|div`, but also `e:div` for names not clashing with pseudo-classes.
* Attributes with or without quotes
  - exists `div[foo]`
  - equals `div[foo=bar]`
  - whitespace separated match `div[foo~=bar]`
  - hyphenated start match `div[foo|=bar]`
  - starts with `div[foo^=bar]`
  - ends with `div[foo$=bar]`
  - substring `div[foo*=bar]`
* Pseudo-classes
  - contains specified text `:contains()`
  - that have no children `:empty`
  - first child of parent `:first-child`
  - last child of parent `:last-child`

## API

### Parsing

##### parseXml

`zu.parseXml(str)`

* `:: s -> ns`

Parse an XML string to an array of nodes.

##### parseHtml

`zu.parseHtml(str)`

Parse an HTML string to an array of nodes. The difference from XML is
that certain HTML elements get special treatment. `<script>` contents
are not further parsed, `<img>` tags does not need closing etc.

* `:: s -> ns`


### Data out

##### xml

`zu.xml(nodes)`

Turn given array of nodes into a string XML form.

* `:: ns -> s`

##### html

`zu.html(nodes)`

Turn given array of nodes into a string HTML form.

* `:: ns -> s`

##### text

`zu.text(nodes)`

Turn given array of text nodes into a string, where the
contents of each node is concatenated together.

* `:: ns -> s`

##### attr

`zu.attr(nodes, name)`

Return the attribute value for `names` from the first element in the
given array of nodes.

* `:: ns, s -> s`

Also `zu.attrWith(nodes or name)`

* `:: ns -> s  -> s`
* `:: s  -> ns -> s`

##### hasClass

Test whether any node in the given array of nodes has a `name` as a
class.

`zu.hasClass(nodes, name)`

* `:: ns, s -> s`

Also `zu.hasClassWith(nodes or name)`

* `:: ns -> s  -> s`
* `:: s  -> ns -> s`



### Selectors

##### find

`zu.find(nodes, exp)`

Match the given nodes, and any descendants of the given nodes against
the given expression.

* `:: ns, s -> ns`

Also `zu.findWith(nodes or exp)`

* `:: s  -> ns -> ns`
* `:: ns -> s  -> ns`

##### children

Match the immediate children of the given nodes against the given
expression. Also `zu.children(nodes)` to get immediate children without
any filtering expression.

`zu.children(nodes, exp)`

* `:: ns, s -> ns`
* `:: ns -> ns`

Also `zu.childrenWith(nodes or exp)`

* `:: s  -> ns -> ns`
* `:: ns -> s  -> ns`

#####  closest

`zu. closest(nodes, exp)`

Test the given set of nodes and recursively parent nodes against
expression and return the first match.

* `:: ns, s -> ns`
* `:: ns -> ns`

Also `zu.closestWith(nodes or exp)`

* `:: s  -> ns -> ns`
* `:: ns -> s  -> ns`

##### filter

`zu.filter(nodes, exp)`

Filter the given set of nodes using the expression. Also
`zu.filter(nodes)` just returns the same nodes (however in a new array).

* `:: ns, s -> ns`
* `:: ns -> ns`

Also `filterWith(nodes or exp)`

* `:: s  -> ns -> ns`
* `:: ns -> s  -> ns`

##### is

`zu.is(nodes, exp)`

Filter the given set of nodes using the expression and tell whether
any matched.

* `:: ns, s -> bool`
* `:: ns -> bool`

Also `zu.isWith(nodes or exp)`

* `:: s  -> ns -> bool`
* `:: ns -> s  -> bool`

##### next

`zu.next(nodes, exp)`

Select immediate sibling nodes to the right of given nodes, optionally
apply a filter expression.

* `:: ns, s -> ns`
* `:: ns -> ns`

Also `zu.nextWith(nodes or exp)`

* `:: s  -> ns -> ns`
* `:: ns -> s  -> ns`

##### nextAll

`zu.nextAll(nodes, exp)`

Select all sibling nodes to the right of the given nodes, optionally
filtered by an expression.

* `:: ns, s -> ns`
* `:: ns -> ns`

Also `zu.nextAllWith(nodes or exp)`

* `:: s  -> ns -> ns`
* `:: ns -> s  -> ns`

##### parent

`zu.parent(nodes, exp)`

Select immediate parent nodes of given nodes, optionally filtered by
an expression.

* `:: ns, s -> ns`
* `:: ns -> ns`

Also `zu.parentWith(nodes or exp)`

* `:: s  -> ns -> ns`
* `:: ns -> s  -> ns`

##### parents

`zu.parents(nodes, exp)`

Select all parent nodes of given nodes, optionally filtered by an
expression.

* `:: ns, s -> ns`
* `:: ns -> ns`

Also `zu.parentsWith(nodes or exp)`

* `:: s  -> ns -> ns`
* `:: ns -> s  -> ns`

##### prev

`zu.prev(nodes, exp)`

Select immediate sibling nodes to the left of given nodes, optionally
apply a filter expression.

* `:: ns, s -> ns`
* `:: ns -> ns`

Also `zu.prevWith(nodes or exp)`

* `:: s  -> ns -> ns`
* `:: ns -> s  -> ns`

##### prevAll

`zu.prevAll(nodes, exp)`

Select all sibling nodes to the left of the given nodes, optionally
filtered by an expression.

* `:: ns, s -> ns`
* `:: ns -> ns`

Also `zu.prevAllWith(nodes or exp)`

* `:: s  -> ns -> ns`
* `:: ns -> s  -> ns`

##### siblings

`zu.siblings(nodes, exp)`

Select all sibling nodes both to the left and right, optionally
filtered by an expression.

* `:: ns, s -> ns`
* `:: ns -> ns`

Also `zu.siblingsWith(nodes or exp)`

* `:: s  -> ns -> ns`
* `:: ns -> s  -> ns`


License
-------

The MIT License (MIT)

Copyright © 2015 Martin Algesten

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


[1]: https://github.com/cheeriojs/cheerio "Cheerio"
[2]: https://github.com/algesten/fnuc     "fnuc"
[3]: https://github.com/ramda/ramda       "Ramda"
[4]: https://en.wikipedia.org/wiki/Currying "Curry"
