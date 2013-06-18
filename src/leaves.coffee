window.Leaves or= {}

Leaves.root_domain = "http://scratch.leaves.io"

Leaves.create = (data_item) ->
  $.ajax Leaves.root_domain + "/json-doc",
    data: JSON.stringify((data_item || {})),
    contentType: "text/plain",
    type: "POST"

Leaves.add = (wl_id, path, data_item) ->
  $.ajax  Leaves.root_domain + "/json-doc/#{ wl_id }/addable/data-path/#{path.join('/')}",
    data: JSON.stringify(data_item),
    contentType: "text/plain",
    type: "POST"

Leaves.assoc = (wl_id, path, data_item) ->
  $.ajax  Leaves.root_domain + "/json-doc/#{ wl_id }/settable/data-path/#{path.join('/')}",
    data: JSON.stringify(data_item),
    contentType: "text/plain",
    type: "POST"

Leaves.move = (wl_id, path, new_key) ->
  $.ajax  Leaves.root_domain + "/json-doc/#{ wl_id }/movable/data-path/#{path.join('/')}",
    data: JSON.stringify(new_key),
    contentType: "text/plain",
    type: "POST"

Leaves.remove = (wl_id, path) ->
  $.ajax  Leaves.root_domain + "/json-doc/#{ wl_id }/deletable/data-path/#{path.join('/')}",
    contentType: "text/plain",
    type: "DELETE"

Leaves.get = (wl_id) ->
  $.ajax  Leaves.root_domain + "/json-doc/#{wl_id}", type: 'GET'

Leaves.get_with_data = (wl_id) ->
  $.ajax  Leaves.root_domain + "/json-doc/#{wl_id}?with_data=true", type: 'GET'

Leaves.get_data_path = (wl_id) ->
  $.ajax  Leaves.root_domain + "/json-doc/#{wl_id}/data-path/#{path.join('/')}", type: 'GET'

Leaves.get_as_of = (wl_id, timestamp) ->
  $.ajax  Leaves.root_domain + "/json-doc/#{wl_id}/time-traveler/as-of/#{timestamp}", type: 'GET'

Leaves.get_since = (wl_id, timestamp) ->
  $.ajax  Leaves.root_domain + "/json-doc/#{wl_id}/time-traveler/since/#{timestamp}", type: 'GET'

Leaves.do_action = (wl_id, action) ->
  args = action.args.slice(0)
  args.unshift(wl_id)
  Leaves[action.verb].apply(Leaves, args)

Leaves.opt_action = (value, action) ->
  args = action.args.slice(0)
  args.unshift(Leaves.JsonOp.deep_clone(value))
  Leaves.JsonOp["#{action.verb}_node"].apply(Leaves, args)

Leaves.log = (wl) -> console.log wl.data

window.Leaves.JsonDoc = class JsonDoc
  constructor: (options = {}) ->
    if options.webmap_id?
      @request = Leaves.get_with_data(options.webmap_id)
    else if options.initial_data?
      @request = Leaves.create(options.initial_data)
    else if !options.action?
      @request = Leaves.create([])
    else
      @action = options.action
      @previous = options.previous
      @request = @previous.request.pipe (wl) =>
        Leaves.do_action wl._id, @action
    @request.done (wl) => @wl = wl

  _get_keys: (keys) -> if keys instanceof Array then keys else [keys]

  set: (key, data_item) ->
    Leaves.JsonDoc.from_action {verb: "assoc", args: [@_get_keys(key), data_item]}, @

  delete: (key) ->
    Leaves.JsonDoc.from_action {verb: "remove", args: [@_get_keys(key)]}, @

  add: (data_item) ->
    @insert_at(-1, data_item)

  insert_at: (key, data_item) ->
    Leaves.JsonDoc.from_action {verb: "add", args: [@_get_keys(key), data_item]}, @

  move_to: (key, new_key) ->
    Leaves.JsonDoc.from_action {verb: "move", args: [@_get_keys(key), new_key]}, @

  get: (key) ->
    Leaves.JsonOp.deep_clone(if @wl? then @wl.data[key] else @opt_value()[key])

  opt_value: () ->
    if !@action? then ((@wl and @wl.data? and @wl.data) || [])
    else Leaves.opt_action @previous.opt_value(), @action

  value: (func) -> @request.done func

  rejected: -> @request.state() == "rejected"
  completed: -> @request.state() == "resolved"
  rejected_in_chain: ->
    if !@action? then false
    else if @completed() then false
    else @rejected() || @previous.rejected_in_chain()
  last_not_rejected: ->
    if !@rejected_in_chain() then @
    else @previous.last_not_rejected()

window.Leaves.JsonDoc.from_identifier = (webmap_id) ->
  new JsonDoc(webmap_id: webmap_id)

window.Leaves.JsonDoc.from_data = (data) ->
  new JsonDoc(initial_data: data)

window.Leaves.JsonDoc.from_action = (action, previous) ->
  new JsonDoc(action: action, previous: previous)

window.Leaves.DocManager = class DocManager
  constructor: (options={}) ->
    @next_pointer_cache = {}
    @change_listeners = []
    @opt_change_listeners = []
    @lpointer = new JsonDoc options
    @lpointer.request.done (wl) =>
      @_trigger_change(wl)
      # really weird bug
      # @_trigger_opt_change(wl.data)

  add: (data_item) ->
    @_swap_pointer(@lpointer.add(data_item)) && @

  set: (key, data_item) ->
    @_swap_pointer(@lpointer.set(key, data_item)) && @

  delete: (key) ->
    @_swap_pointer(@lpointer.delete(key)) && @

  insert_at: (key, data_item) ->
    @_swap_pointer(@lpointer.insert_at(key, data_item)) && @

  move_to: (key, new_key) ->
    @_swap_pointer(@lpointer.move_to(key, new_key)) && @

  get: (key) -> @lpointer.get(key)

  opt_value: () -> @lpointer.opt_value()

  value: (func) -> @lpointer.value func

  path: (path_array) -> new Leaves.PathProxy(path_array, @)

  undo: () ->
    if @lpointer.previous?
      @next_pointer_cache[@lpointer.previous.wl._id] = @lpointer
      @_swap_pointer @lpointer.previous
    else if @lpointer.wl["parent-id"]?
      ref = new JsonDoc webmap_id: @lpointer.wl["parent-id"]
      ref.request.done =>
        @next_pointer_cache[ref.wl._id] = @lpointer
        @_swap_pointer ref

  redo: () ->
    next = @next_pointer_cache[@lpointer.wl._id]
    if next?
      @_swap_pointer next

  changed: (func) -> @change_listeners.push(func)
  optimistic_changed: (func) -> @opt_change_listeners.push(func)

  _swap_pointer: (next_lpointer) ->
        
    @_trigger_opt_change(next_lpointer.opt_value())
    next_lpointer.request.done (wl) => @_trigger_change(wl)
    next_lpointer.request.fail (wl) =>
      if @lpointer.rejected_in_chain()
        @_swap_pointer(@lpointer.last_not_rejected())
    @lpointer = next_lpointer

  _trigger_change: (wl) -> l(wl.data, wl) for l in @change_listeners
  _trigger_opt_change: (val) -> l(val) for l in @opt_change_listeners

window.Leaves.DocManager.from_identifier = (webmap_id) ->
  new DocManager(webmap_id: webmap_id)

window.Leaves.DocManager.from_data = (data) ->
  new DocManager(initial_data: data)

window.Leaves.DocManager.from_cookie = (cookie_name, intial_data) ->
  webmap_id = Cookies.get cookie_name
  lm = if webmap_id?
    Leaves.DocManager.from_identifier(webmap_id)
  else
    Leaves.DocManager.from_data(intial_data)
  console.log lm
  lm.changed (val, wl) ->
    Cookies.set cookie_name, wl._id, expires: (86400 * 300)
  lm

window.Leaves.PathProxy = class PathProxy
  contructor: (path_array, parent) ->
    @parent = parent
    @path = path_array

  add: (data_item) ->
    @parent.insert_at(@path.concat([-1]), data_item) && @

  set: (key, data_item) ->
    @parent.set(@path.concat([key]), data_item) && @

  delete: (key) ->
    @parent.delete(@path.concat([key])) && @

  insert_at: (key, data_item) ->
    @parent.insert_at(@path.concat([key]), data_item) && @

  move_to: (key, new_key) ->
    @parent.move_to(@path.concat([key]), new_key) && @

window.Leaves.TimeView = class TimeView
  constructor: (wl, timestamp, func_name = "get_as_of") ->
    @original_wl = wl
    @change_listeners = []
    @func_name = func_name
    @travel(timestamp)

  changed: (func) -> @change_listeners.push func
  _trigger_change: (wl) -> l(wl.data, wl) for l in @change_listeners

  value: (func) -> @request.done (wl) -> func(wl.data)

  travel: (timestamp) ->
    @request = Leaves[@func_name] @original_wl._id, timestamp
    @request.done (wl) =>
      @_trigger_change(wl)

window.Leaves.as_of_view = (wl, timestamp) -> new Leaves.TimeView(wl, timestamp, "get_as_of")
window.Leaves.since_view = (wl, timestamp) -> new Leaves.TimeView(wl, timestamp, "get_since")
