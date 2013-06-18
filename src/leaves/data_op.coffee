window.Leaves or= {}

window.Leaves.JsonOp or= {}

((ns) ->
  ns.apply_to_node = (struct, key_chain, func) ->
    current_key = key_chain[0]
    struct = struct || if typeof current_key == "number" then [] else {}
    if !current_key?
      func(struct)
    else
      struct[current_key] = ns.apply_to_node(struct[current_key],
        key_chain.slice(1), func)
      struct

  ns.insert_into_array = (arr, key, data) ->
    if key == -1
      arr.push(data)
    else
      arr.splice(key, 0, data)
    arr

  ns.insert_at = (struct, key, data) ->
    if !struct? && typeof key == "number"
      ns.insert_at [], key, data
    else if !struct?
      ns.insert_at {}, key, data
    else if struct instanceof Array
      ns.insert_into_array struct, key, data
    else if typeof struct == "object"
      struct[key] = data; struct
    else
      throw "must be either array or object or nil"

  ns.remove_from_vec = (arr, key) ->
    arr.slice(0,key).concat(arr.slice(key + 1))

  ns.remove_at = (struct, key) ->
    if !struct? then null
    else if struct instanceof Array
      ns.remove_from_vec struct, key
    else if typeof struct == "object"
      delete struct[key]
      struct
    else
      struct

  ns.move_to = (struct, old_key, new_key) ->
    temp = struct[old_key]
    removed = ns.remove_at struct, old_key
    ns.insert_at(removed, new_key, temp)

  ns.assoc_node = (struct, key_chain, datum) ->
    if key_chain.length == 0
      datum
    else
      ns.apply_to_node(struct,
        key_chain.slice(0, -1),
        (n) -> n[key_chain.slice(-1)[0]] = datum; n)

  ns.add_node = (struct, key_chain, data) ->
    ns.apply_to_node(struct,
      key_chain.slice(0, -1),
        (n) -> ns.insert_at(n, key_chain.slice(-1)[0], data))

  ns.remove_node = (struct, key_chain) ->
    ns.apply_to_node(struct,
      key_chain.slice(0, -1),
      (n) -> ns.remove_at(n, key_chain.slice(-1)[0]))

  ns.move_node = (struct, key_chain, new_key) ->
    ns.apply_to_node(struct,
      key_chain.slice(0, -1),
      (n) -> ns.move_to(n, key_chain.slice(-1)[0], new_key))

  ns.deep_clone = (obj) ->
    $.extend(true, {}, {data: obj}).data)(Leaves.JsonOp)
