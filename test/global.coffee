global.chai   = require 'chai'
global.assert = chai.assert
global.expect = chai.expect

# helper node comparison function
global.eql = (nodes, cmp) ->
    if typeof nodes == 'object'
        assert.equal nodes.toString(), cmp
    else
        assert.deepEqual nodes.map((n)->n.toString()), cmp
