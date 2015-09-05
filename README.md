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

* Selectors returns `Array`s, not "array-like objects". This means
  functional libraries such as [fnuc][2] and [Ramda][3] can
  interoperate.

* Reading, not manipulating. This cuts out a lot of code as well as
  avoids awkward jQuery style dual-purpose functions (get/set).

* Performance. Especially matching should be fast.

* XML bias. HTML is the odd one out. Namespaces do not need escaping
  in selector expressions (`zu.find nodes, 'e:event'`).

### Curry

Each `zu.[something]` that takes two arguments also have a curried
version `zu.[something]With` Example illustrated with `zu.parent`.

##### Both arguments

`:: ns, s -> ns`

No curry here.

```javascript
zu.parent(nodes, exp);
```

##### One argument

`:: ns -> ns`

Equivalent to having `null` as second argument.

```javascript
zu.parent(nodes);
```

##### Partially applied nodes

`:: ns -> s -> ns`

Provided an array, gives a function expecting the expression.

```javascript
zu.parentWith(nodes);
```

##### Partially applied with expression

`:: s -> ns -> ns`

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
* Attributes with or without quotes
  - exists `div[foo]`
  - equals `div[foo=bar]`
  - whitespace separated match `div[foo~=bar]`
  - hyphenated start match `div[foo|=bar]`
  - starts with `div[foo^=bar]`
  - ends with `div[foo$=bar]`
  - substring `div[foo*=bar]`

## API

### Parsing

##### parseXml(str)

`:: s -> ns`

Parse an XML string to an array of nodes.

##### parseHtml(str)

`:: s -> ns`

Parse an HTML string to an array of nodes. The difference from XML is
that certain HTML elements get special treatment. `<script>` contents
are not further parsed, `<img>` tags does not need closing etc.



### Data out

##### xml(nodes)

`:: ns -> s`

Turn given array of nodes into a string XML form.

##### html(nodes)

`:: ns -> s`

Turn given array of nodes into a string HTML form.

##### text(nodes)

`:: ns -> s`

Turn given array of text nodes into a string, where the
contents of each node is concatenated together.

##### attr(nodes, name)

* `:: ns, s -> s`

Also `attrWith(nodes or name)`

* `:: ns -> s  -> s`
* `:: s  -> ns -> s`

Return the attribute value for `names` from the first element in the
given array of nodes.

##### hasClass(nodes, name)

* `:: ns, s -> s`

Also `hasClassWith(nodes or name)`

* `:: ns -> s  -> s`
* `:: s  -> ns -> s`

Test whether any node in the given array of nodes has a `name` as a
class.



### Selectors

##### find(nodes, exp)

* `:: ns, s -> ns`

Also `findWith(nodes or exp)`

* `:: s  -> ns -> ns`
* `:: ns -> s  -> ns`

Match the given nodes, and any descendants of the given nodes against
the given expression.

##### children(nodes, exp)

* `:: ns, s -> ns`
* `:: ns -> ns`

Also `childrenWith(nodes or exp)`

* `:: s  -> ns -> ns`
* `:: ns -> s  -> ns`

Match the immediate children of the given nodes against the given
expression. Also `children(nodes)` to get immediate children without
any filtering expression.

#####  closest(nodes, exp)

* `:: ns, s -> ns`
* `:: ns -> ns`

Also `closestWith(nodes or exp)`

* `:: s  -> ns -> ns`
* `:: ns -> s  -> ns`

Test the given set of nodes and recursively parent nodes against
expression and return the first match.

##### filter(nodes, exp)

* `:: ns, s -> ns`
* `:: ns -> ns`

Also `filterWith(nodes or exp)`

* `:: s  -> ns -> ns`
* `:: ns -> s  -> ns`

Filter the given set of nodes using the expression. Also
`filter(nodes)` just returns the same nodes (however in a new array).

##### is(nodes, exp)

* `:: ns, s -> bool`
* `:: ns -> bool`

Also `isWith(nodes or exp)`

* `:: s  -> ns -> bool`
* `:: ns -> s  -> bool`

Filter the given set of nodes using the expression and tell whether
any matched.

##### next(nodes, exp)

* `:: ns, s -> ns`
* `:: ns -> ns`

Also `nextWith(nodes or exp)`

* `:: s  -> ns -> ns`
* `:: ns -> s  -> ns`

Select immediate sibling nodes to the right of given nodes, optionally
apply a filter expression.

##### nextAll(nodes, exp)

* `:: ns, s -> ns`
* `:: ns -> ns`

Also `nextAllWith(nodes or exp)`

* `:: s  -> ns -> ns`
* `:: ns -> s  -> ns`

Select all sibling nodes to the right of the given nodes, optionally
filtered by an expression.

##### parent(nodes, exp)

* `:: ns, s -> ns`
* `:: ns -> ns`

Also `parentWith(nodes or exp)`

* `:: s  -> ns -> ns`
* `:: ns -> s  -> ns`

Select immediate parent nodes of given nodes, optionally filtered by
an expression.

##### parents(nodes, exp)

* `:: ns, s -> ns`
* `:: ns -> ns`

Also `parentsWith(nodes or exp)`

* `:: s  -> ns -> ns`
* `:: ns -> s  -> ns`

Select all parent nodes of given nodes, optionally filtered by an
expression.

##### prev(nodes, exp)

* `:: ns, s -> ns`
* `:: ns -> ns`

Also `prevWith(nodes or exp)`

* `:: s  -> ns -> ns`
* `:: ns -> s  -> ns`

Select immediate sibling nodes to the left of given nodes, optionally
apply a filter expression.

##### prevAll(nodes, exp)

* `:: ns, s -> ns`
* `:: ns -> ns`

Also `prevAllWith(nodes or exp)`

* `:: s  -> ns -> ns`
* `:: ns -> s  -> ns`

Select all sibling nodes to the left of the given nodes, optionally
filtered by an expression.

##### siblings(nodes, exp)

* `:: ns, s -> ns`
* `:: ns -> ns`

Also `siblingsWith(nodes or exp)`

* `:: s  -> ns -> ns`
* `:: ns -> s  -> ns`

Select all sibling nodes both to the left and right, optionally
filtered by an expression.


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
