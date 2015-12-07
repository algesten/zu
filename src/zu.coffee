{zipwith, set, mixin, keys, values, converge} = require 'fnuc'
hasclass  = require './hasclass'

# fn can be partially applied either with an array or an expression.
withcurry = (fn) -> (a) ->
    if a.constructor == String then ((ns)  -> fn ns, a) else ((exp) -> fn a, exp)

# key fooWith for foo
withk = (s) -> "#{s}With"

# for an object a:fn make an object with [{a:fn, aWith:withcurry(fn)}]
# for each k/v pair.
withify = do ->
    z = (k, fn) -> set(withk(k), withcurry(fn)) set({}, k, fn)
    converge keys, values, zipwith(z)

arg1 = require './domparser'

arg2 = mixin {
    attr:      (ns, name) -> (if ns instanceof Array then ns[0] else ns)?.attribs?[name]
    hasClass:  (ns, name) -> return true for n in ns when hasclass(n, name); return false
    }, require './selectors'


module.exports = zu = mixin arg1, withify(arg2)...
