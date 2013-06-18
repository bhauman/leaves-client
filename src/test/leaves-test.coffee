module "JsonDoc"

# only for testing failures
Leaves._failer = (wl_id) ->
  res = $.Deferred()
  setTimeout (-> res.reject()), 5
  res
Leaves.JsonOp._failer_node = (value) ->
        value.push("__failer__") && value
Leaves.JsonDoc.prototype._failer = () ->
  Leaves.JsonDoc.from_action {verb: "_failer", args: []}, @
Leaves.DocManager.prototype._failer = () ->
  @_swap_pointer(@lpointer._failer()) && @

test "JsonDoc can be instantiated", ->
  list = new JsonDoc
  equal list.action, null
  equal list.previous, null

test "adding item to list", ->
  list = new JsonDoc
  new_list = list.add 3
  ok list.action != new_list.action
  ok list.previous != new_list.previous
  deepEqual new_list.action, {verb:"add", args: [[-1], 3]}

asyncTest "new empty list should have request of empty list", ->
  list = new JsonDoc
  list.request.done (wl) ->
    deepEqual wl.data, []
    start()

test "opt_value for empty list is []", ->
  list = new JsonDoc
  deepEqual list.opt_value(), []

asyncTest "opt_value for added list should work",2, ->
  list = new JsonDoc
  nlist = list.add(5)
  deepEqual nlist.opt_value(), [5]
  nlist.value (wl) ->
    deepEqual wl.data, [5]
    start()

asyncTest "chaining opt value", ->
  l = (new JsonDoc).add(1).add(2).add(3).add(4)
  l.value (wl) ->
    deepEqual wl.data, [1,2,3,4]
    start()

asyncTest "build with existing Id", 2, ->
  l = (new JsonDoc).add(1).add(2).add(3).add(4)
  deepEqual l.opt_value(), [1,2,3,4]
  l.value (wl) ->
    JsonDoc.from_identifier(wl._id).value (wln) ->
      deepEqual wln.data, [1,2,3,4]
      start()

asyncTest "build with data", 1, ->
  JsonDoc.from_data({bob: 5, bill: [1,2]}).value (wln) ->
    deepEqual wln.data, {bob: 5, bill: [1,2]}
    start()

asyncTest "can call set on hash", ->
  dr = JsonDoc.from_data({}).set("bobo", 5).set("john", 6)
  dr.value (wl) ->
    deepEqual wl.data, {bobo: 5, john: 6}
    start()

asyncTest "can call set on array", ->
  dr = JsonDoc.from_data([0,1,2]).set(0, "bob").set(2, "john")
  dr.value (wl) ->
    deepEqual wl.data, ["bob", 1, "john"]
    start()

asyncTest "can call set on hash with array of keys", ->
  dr = JsonDoc.from_data({}).set(["bobo", "jo"], 5).set(["bobo","john"], 6)
  dr.value (wl) ->
    deepEqual wl.data, {bobo: {jo: 5, john: 6}}
    start()

asyncTest "can call set on array with array of keys", ->
  dr = JsonDoc.from_data([]).set([0, "jo"], 5).set([1,"john"], 6)
  dr.value (wl) ->
    deepEqual wl.data, [{jo: 5}, {john: 6}]
    start()

asyncTest "insert_at on hash", ->
  dr = JsonDoc.from_data({}).insert_at("bobo", 5).insert_at("john", 6)
  dr.value (wl) ->
    deepEqual wl.data, {bobo: 5, john: 6}
    start()

asyncTest "insert_at on array", ->
  dr = JsonDoc.from_data([0,1,2]).insert_at(0, "bob").insert_at(1, "john")
  dr.value (wl) ->
    deepEqual wl.data, ["bob", "john", 0, 1, 2]
    start()

asyncTest "insert_at on hash with array of keys", ->
  dr = JsonDoc.from_data({}).insert_at(["bobo", "jo"], 5).insert_at(["bobo", "john"], 6)
  dr.value (wl) ->
    deepEqual wl.data, {bobo: {jo: 5, john: 6}}
    start()

asyncTest "move_to on hash", ->
  dr = JsonDoc.from_data({bobo: 5, john: 6}).move_to("bobo", "babbet")
  dr.value (wl) ->
    deepEqual wl.data, {babbet: 5, john: 6}
    start()

asyncTest "move_to on array", ->
  dr = JsonDoc.from_data([0,1,2]).move_to(0, 2)
  dr.value (wl) ->
    deepEqual wl.data, [1, 2, 0]
    start()

asyncTest "move_to on array with array of keys", ->
  dr = JsonDoc.from_data({bobo: [0,1,2]}).move_to(["bobo", 0], 2)
  dr.value (wl) ->
    deepEqual wl.data, {bobo: [1, 2, 0]}
    start()

asyncTest "can call get on hash", 3, ->
  dr = JsonDoc.from_data({}).set("bobo", 5).set("john", 6)
  equal dr.get("bobo"), 5
  dr.value (wl) ->
    equal dr.get("bobo"), 5
    equal dr.get("john"), 6
    start()

asyncTest "can call get on array", 5, ->
  dr = JsonDoc.from_data([0,1,2]).set(0, "bob").set(2, "john")
  equal dr.get(0), "bob"
  equal dr.get(2), "john"
  dr.value (wl) ->
    equal dr.get(0), "bob"
    equal dr.get(2), "john"
    deepEqual wl.data, ["bob", 1, "john"]
    start()

asyncTest "delete keys from array", ->
  dr = JsonDoc.from_data([0,1,2]).delete(0).delete(0)
  dr.value (wl) ->
    equal dr.get(0), 2
    deepEqual wl.data, [2]
    start()

asyncTest "delete keys from hash", ->
  dr = JsonDoc.from_data({}).set("bobo", 5).set("john", 6).delete("bobo")
  dr.value (wl) ->
    deepEqual wl.data, {john: 6}
    start()

module "DocManager"

asyncTest "new empty listmanager", 2, ->
  lm = new DocManager
  lm.changed (val) ->
    deepEqual lm.opt_value(), []
    deepEqual val, []
    start()

asyncTest "add a value trigger opt change", ->
  lm = new DocManager
  counter = 0
  expected  = []
  lm.optimistic_changed (val) ->
    expected.push(counter++)
    deepEqual val, expected
    start() if expected.length == 3
  lm.add(0).add(1).add(2)

asyncTest "add a value trigger value change", ->
  lm = new DocManager
  counter = 0
  expected  = []
  lm.changed (val) ->
    deepEqual val, expected
    expected.push(counter++)
    start() if expected.length == 3
  lm.add(0).add(1).add(2)

asyncTest "testing the fail listener of _swap_pointer",  ->
  lm = new DocManager

  opt_changes  = []
  lm.optimistic_changed (val) -> opt_changes.push(val)

  changes  = []
  lm.changed (val) -> changes.push(val)
  lm.add(0).add(1).add(2)._failer().add(3).add(4)

  setTimeout((->
    # has correct progression
    deepEqual opt_changes, [
                            [0],
                            [0,1],
                            [0,1,2],
                            [0,1,2,"__failer__"],
                            [0,1,2,"__failer__", 3],
                            [0,1,2,"__failer__", 3, 4],
                            [0,1,2]]

    # this is getting called one extra time on failure
    deepEqual changes, [[], [0], [0,1], [0,1,2], [0,1,2]]
    # is pointing at last finished action
    deepEqual lm.lpointer.action, {verb: "add", args: [[-1], 2]}
    start()), 300)

module "JsonOp"

data_op = Leaves.JsonOp

test "apply to node", ->
  struct = a: 1, b: 2
  deepEqual data_op.apply_to_node(struct, [], (x) -> x), struct
  struct = a: 1, b: 2
  deepEqual data_op.apply_to_node(struct, ["base"], (x) -> x["a"] = 3; x),
            {a: 1, b: 2, base: {a: 3}}
  struct = a: 1, b: 2
  deepEqual data_op.apply_to_node(struct, ["base", "case"], (x) -> x["a"] = 3; x),
            {a: 1, b: 2, base: {case: {a: 3}}}
  struct = a: 1, b: 2
  deepEqual data_op.apply_to_node(struct, ["c", 0, "r"], (x) -> x["a"] = 3; x),
            {a: 1, b: 2, c: [{r: {a: 3}}]}
  struct = a: 1, b: 2
  deepEqual data_op.apply_to_node(struct, ["c", 0, "r"], (x) -> x; x),
            {a: 1, b: 2, c: [{r: {}}]}

test "assoc_node", ->
  deepEqual data_op.assoc_node({}, ["bob"], 5), {bob: 5}
  deepEqual data_op.assoc_node({}, ["bob", "green"], 5), {bob: {green:5}}
  equal data_op.assoc_node({}, [], 35), 35

test "insert_into_array", ->
  deepEqual data_op.insert_into_array([], 0, 5), [5]
  deepEqual data_op.insert_into_array([], -1, 5), [5]
  deepEqual data_op.insert_into_array([1], 0, 5), [5, 1]
  deepEqual data_op.insert_into_array([1], -1, 5), [1, 5]

test "insert_at", ->
  deepEqual data_op.insert_at([], 0, 5), [5]
  deepEqual data_op.insert_at([], -1, 5), [5]
  deepEqual data_op.insert_at([1], 0, 5), [5, 1]
  deepEqual data_op.insert_at([1], -1, 5), [1, 5]
  deepEqual data_op.insert_at(null, "bob", 5), {bob: 5}
  deepEqual data_op.insert_at(null, -1, 5), [5]
  deepEqual data_op.insert_at({hey: 999}, "george", 5), {hey: 999, george: 5}

test "add_node", ->
  deepEqual data_op.add_node([], [0], 5), [5]
  deepEqual data_op.add_node([], [-1], 5), [5]
  deepEqual data_op.add_node([1], [0], 5), [5, 1]
  deepEqual data_op.add_node([1], [-1], 5), [1, 5]
  deepEqual data_op.add_node({bob: [1]}, ["bob", -1], 5), {bob: [1, 5]}
  deepEqual data_op.add_node({bob: [1]}, ["george", "john"], 5),
                             {bob: [1], george: { john: 5 } }

test "remove_from_vec", ->
  deepEqual data_op.remove_from_vec( [777], 0 ), []
  deepEqual data_op.remove_from_vec( [777, 888], 0 ), [888]
  deepEqual data_op.remove_from_vec( [777, 888], 1 ), [777]
  deepEqual data_op.remove_from_vec( [777, 888, 999], 1 ), [777, 999]
  deepEqual data_op.remove_from_vec( [777, 888, 999], 2 ), [777, 888]

test "remove_at", ->
  equal data_op.remove_at(null, 5), null
  deepEqual data_op.remove_at( {}, 5 ), {}
  deepEqual data_op.remove_at( {hey: 5}, "hey" ), {}
  deepEqual data_op.remove_at( {hey: 5, there: 7}, "hey" ), {there: 7}
  deepEqual data_op.remove_at( [777, 888, 999], 1 ), [777, 999]
  deepEqual data_op.remove_at( [777, 888, 999], 2 ), [777, 888]

test "move_to", ->
  deepEqual data_op.move_to([0,1,2,3,4], 0, 4), [1,2,3,4,0]
  deepEqual data_op.move_to([0,1,2,3,4], 0, 3), [1,2,3,0,4]
  deepEqual data_op.move_to([0,1,2,3,4], 0, 0), [0,1,2,3,4]
  deepEqual data_op.move_to({bill: 5}, "bill", "bob"), {bob: 5}

test "move_node", ->
  deepEqual data_op.move_node([0,1,2,3,4], [0], 4), [1,2,3,4,0]
  deepEqual data_op.move_node({bill: [0,1,2,3,4]}, ["bill", 0], 4), {bill: [1,2,3,4,0]}

test "remove_node", ->
  deepEqual data_op.remove_node([0,1,2,3,4], [0]), [1,2,3,4]
  deepEqual data_op.remove_node({bill: [0,1,2,3,4]}, ["bill", 0], 4), {bill: [1,2,3,4]}
