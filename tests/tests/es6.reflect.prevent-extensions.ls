{module, test} = QUnit
module \ES6

{defineProperty, isExtensible} = Object

test 'Reflect.preventExtensions' (assert)->
  {preventExtensions} = Reflect
  assert.isFunction preventExtensions
  assert.arity preventExtensions, 1
  assert.name preventExtensions, \preventExtensions
  assert.looksNative preventExtensions
  obj = {}
  assert.ok preventExtensions(obj), on
  if DESCRIPTORS
    assert.ok !isExtensible obj
  assert.throws (-> preventExtensions 42), TypeError, 'throws on primitive'