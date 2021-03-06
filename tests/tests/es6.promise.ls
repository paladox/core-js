'use strict'
{module, test} = QUnit
module \ES6

test 'Promise' !(assert)->
  assert.isFunction Promise
  assert.arity Promise, 1
  assert.name Promise, \Promise
  assert.looksNative Promise
  assert.throws (!-> Promise!), 'throws w/o `new`'
  new Promise (resolve, reject)!->
    assert.isFunction Promise, 'resolver is function'
    assert.isFunction Promise, 'rejector is function'
    assert.same @, (-> @)!, 'correct executor context'

# related https://github.com/zloirock/core-js/issues/78
if DESCRIPTORS => test 'Promise operations order' !(assert)->
  assert.expect 1
  expected = \DEHAFGBC
  async = assert.async!
  result = ''
  var resolve
  p = new Promise (r)!-> resolve := r
  resolve then: !->
    result += \A
    throw Error!
  p.catch !-> result += \B
  p.catch !->
    result += \C
    assert.same result, expected
    async!
  var resolve2
  p2 = new Promise (r)!-> resolve2 := r
  resolve2 Object.defineProperty {}, \then, get: !->
    result += \D
    throw Error!
  result += \E
  p2.catch !-> result += \F
  p2.catch !-> result += \G
  result += \H
  setTimeout (!-> if ~result.indexOf(\C) => assert.same result, expected), 1e3

test 'Promise#then' !(assert)->
  assert.isFunction Promise::then
  assert.arity Promise::then, 2
  assert.name Promise::then, \then
  assert.looksNative Promise::then

test 'Promise#catch' !(assert)->
  assert.isFunction Promise::catch
  assert.arity Promise::catch, 1
  NATIVE and assert.name Promise::catch, \catch # can't be polyfilled in some environments
  assert.looksNative Promise::then

test 'Promise#@@toStringTag' !(assert)->
  assert.ok Promise::[Symbol.toStringTag] is \Promise, 'Promise::@@toStringTag is `Promise`'

test 'Promise.all' !(assert)->
  assert.isFunction Promise.all
  assert.arity Promise.all, 1
  assert.name Promise.all, \all
  assert.looksNative Promise.all
  # works with iterables
  iter = createIterable [1 2 3]
  Promise.all iter .catch ->
  assert.ok iter.received, 'works with iterables: iterator received'
  assert.ok iter.called, 'works with iterables: next called'
  # call @@iterator in Array with custom iterator
  a = []
  done = no
  a[Symbol?iterator] = ->
    done := on
    [][Symbol?iterator]call @
  Promise.all a
  assert.ok done

test 'Promise.race' !(assert)->
  assert.isFunction Promise.race
  assert.arity Promise.race, 1
  assert.name Promise.race, \race
  assert.looksNative Promise.race
  # works with iterables
  iter = createIterable [1 2 3]
  Promise.race iter .catch ->
  assert.ok iter.received, 'works with iterables: iterator received'
  assert.ok iter.called, 'works with iterables: next called'
  # call @@iterator in Array with custom iterator
  a = []
  done = no
  a[Symbol?iterator] = ->
    done := on
    [][Symbol?iterator]call @
  Promise.race a
  assert.ok done

test 'Promise.resolve' !(assert)->
  assert.isFunction Promise.resolve
  assert.arity Promise.resolve, 1
  assert.name Promise.resolve, \resolve
  assert.looksNative Promise.resolve

test 'Promise.reject' !(assert)->
  assert.isFunction Promise.reject
  assert.arity Promise.reject, 1
  assert.name Promise.reject, \reject
  assert.looksNative Promise.reject

if PROTO
  test 'Promise subclassing' !(assert)->
    # this is ES5 syntax to create a valid ES6 subclass
    SubPromise = ->
      self = new Promise it
      Object.setPrototypeOf self, SubPromise::
      self.mine = 'subclass'
      self
    Object.setPrototypeOf SubPromise, Promise
    SubPromise:: = Object.create Promise::
    SubPromise::@@ = SubPromise
    # now let's see if this works like a proper subclass.
    p1 = SubPromise.resolve 5
    assert.strictEqual p1.mine, 'subclass'
    p1 = p1.then -> assert.strictEqual it, 5
    assert.strictEqual p1.mine, 'subclass'
    p2 = new SubPromise -> it 6
    assert.strictEqual p2.mine, 'subclass'
    p2 = p2.then -> assert.strictEqual it, 6
    assert.strictEqual p2.mine, 'subclass'
    p3 = SubPromise.all [p1, p2]
    assert.strictEqual p3.mine, 'subclass'
    # double check
    assert.ok p3 instanceof Promise
    assert.ok p3 instanceof SubPromise
    # check the async values
    p3.then assert.async!, -> assert.ok it, no
