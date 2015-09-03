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

* XML bias. HTML is the odd one out. Namespaces do not need escaping
  in selector expressions.

### Curry

Two argument functions are curried. For all [selectors](#selectors)
the curry takes these forms (illustrated by `children`, but applicable
to all selectors).

##### Both arguments

No curry here.

```coffee
zu.children(nodes, selector)
```

##### Binding a selector

Partial application of (string) expression.

```javascript
var sel  = zu.children(expr);   // sel is a function operating on node
var subs = sel(nodes)           // apply sel on nodes to get some children
```

##### No expression

This form may be surprising for functional purists. It's a compromise
to allow use of the selection functions without a "filtering"
selection expression.

```javascript
var subs = zu.children(nodes);      // no selector, just get all children
```

## CSS Selectors

The following selectors are (currently) supported:

* Descendant `div span`
* Child `div > span`. Also works as `> span` for immediate children.
* Class `div.foo`
* Id `div#bar`
* Attribute with or without quotes
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

Parse an XML string to an array of nodes.

##### parseHtml(str)

Parse an HTML string to an array of nodes. The difference from XML is
that certain HTML elements get special treatment. `<script>` contents
are not further parsed, `<img>` tags does not need closing etc.



### Data out

##### xml(nodes)

Turn given array of nodes into a string XML form.

##### html(nodes)

Turn given array of nodes into a string HTML form.

##### text(nodes)

Turn given array of text nodes into a string, where the
contents of each node is concatenated together.

##### attr(nodes, name)

Return the attribute value for `names` from the first element in the
given array of nodes.

##### hasClass(nodes, name)

Test whether any node in the given array of nodes has a `name` as a
class.



### Selectors

##### find(nodes, exp)

* `:: ns, s -> ns`
* `:: s -> ns -> ns`

Match the given nodes, and any descendants of the given nodes against
the given expression.

##### children(nodes, exp)

* `:: ns, s -> ns`
* `:: s -> ns -> ns`
* `:: ns -> ns`

Match the immediate children of the given nodes against the given
expression. Also `children(nodes)` to get immediate children without
any filtering expression.

#####  closest(nodes, exp)

* `:: ns, s -> ns`
* `:: s -> ns -> ns`

Test the given set of nodes and recursively parent nodes against
expression and return the first match.

##### filter(nodes, exp)

* `:: ns, s -> ns`
* `:: s -> ns -> ns`
* `:: ns -> ns`

Filter the given set of nodes using the expression. Also
`filter(nodes)` just returns the same nodes (however in a new array).

##### is(nodes, exp)

* `:: ns, s -> bool`
* `:: s -> ns -> bool`
* `:: ns -> bool`

Filter the given set of nodes using the expression and tell whether
any matched.

##### next(nodes, exp)

* `:: ns, s -> ns`
* `:: s -> ns -> ns`
* `:: ns -> ns`

Select immediate sibling nodes to the right of given nodes, optionally
apply a filter expression.

##### nextAll(nodes, exp)

* `:: ns, s -> ns`
* `:: s -> ns -> ns`
* `:: ns -> ns`

Select all sibling nodes to the right of the given nodes, optionally
filtered by an expression.

##### parent(nodes, exp)

* `:: ns, s -> ns`
* `:: s -> ns -> ns`
* `:: ns -> ns`

Select immediate parent nodes of given nodes, optionally filtered by
an expression.

##### parents(nodes, exp)

* `:: ns, s -> ns`
* `:: s -> ns -> ns`
* `:: ns -> ns`

Select all parent nodes of given nodes, optionally filtered by an
expression.

##### prev(nodes, exp)

* `:: ns, s -> ns`
* `:: s -> ns -> ns`
* `:: ns -> ns`

Select immediate sibling nodes to the left of given nodes, optionally
apply a filter expression.

##### prevAll(nodes, exp)

* `:: ns, s -> ns`
* `:: s -> ns -> ns`
* `:: ns -> ns`

Select all sibling nodes to the left of the given nodes, optionally
filtered by an expression.

##### siblings(nodes, exp)

* `:: ns, s -> ns`
* `:: s -> ns -> ns`
* `:: ns -> ns`

Select all siblong nodes both to the left and right, optionally
filtered by an expression.


[1]: https://github.com/cheeriojs/cheerio "Cheerio"
[2]: https://github.com/algesten/fnuc     "fnuc"
[3]: https://github.com/ramda/ramda       "Ramda"
[4]: https://en.wikipedia.org/wiki/Currying "Curry"
