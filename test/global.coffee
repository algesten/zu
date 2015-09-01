global.chai   = require 'chai'
global.assert = chai.assert
global.expect = chai.expect

# helper node comparison function
global.eql = (nodes, cmp) ->
    if Array.isArray nodes
        assert.deepEqual nodes.map((n)->n.toString()), cmp
    else
        assert.equal nodes.toString(), cmp
