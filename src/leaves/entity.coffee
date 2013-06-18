window.Weblist or= {}

window.Weblist.EntityRemote = {}

Weblist.EntityPusher = {}

Weblist.EntityPusher.setup = (pusher_id) ->
  Weblist.EntityPusher.pusher = new Pusher(pusher_id);

Weblist.EntityRemote.create = (data_item) ->
  $.ajax "/entity",
    data: JSON.stringify((data_item || {})),
    contentType: "application/json",
    type: "POST"

Weblist.EntityRemote.create_from_wl_id = (wl_id) ->
  $.ajax "/entity/from-ref/#{wl_id}",
    contentType: "application/json",
    type: "POST"

Weblist.EntityRemote.add = (e_id, path, data_item) ->
  $.ajax "/entity/#{ e_id }/#{path.join('/')}?op=add",
    data: JSON.stringify(data_item),
    contentType: "application/json",
    type: "POST"

Weblist.EntityRemote.assoc = (e_id, path, data_item) ->
  $.ajax "/entity/#{ e_id }/#{path.join('/')}",
    data: JSON.stringify(data_item),
    contentType: "application/json",
    type: "POST"

Weblist.EntityRemote.remove = (e_id, path) ->
  $.ajax "/entity/#{ e_id }/#{path.join('/')}",
    contentType: "application/json",
    type: "DELETE"

Weblist.EntityRemote.move = (e_id, path, new_key) ->
  $.ajax "/entity/#{ e_id }/#{path.join('/')}?op=move",
    data: JSON.stringify(new_key),
    contentType: "application/json",
    type: "POST"

Weblist.EntityRemote.get = (e_id) ->
  $.ajax "/entity/#{e_id}", type: 'GET'

Weblist.EntityRemote.do_action = (e_id, action) ->
  args = action.args.slice(0)
  args.unshift(e_id)
  Weblist.EntityRemote[action.verb].apply(Weblist, args)

window.Weblist.Entity = class Entity
  constructor: (options = {}) ->
    @change_listeners = []
    if options.entity_id?
      @ent_id  = options.entity_id
      @request = Weblist.EntityRemote.get(options.entity_id)
    @request.done (wl) => @wl = wl

  add: (data_item) ->
    @request = Weblist.EntityRemote.add(@ent_id, [-1], data_item)
    @request.done (wl) => @_swap_wl(wl)

  value: (func) -> @request.done func

  changed: (func) -> @change_listeners.push(func)

  _trigger_change: (wl) -> l(wl.data, wl) for l in @change_listeners

  _swap_wl: (wl) ->
    @wl = wl
    @_trigger_change(wl)

window.Weblist.LiveEntity = class LiveEntity
  constructor: (options = {}) ->
    @change_listeners = []
    if options.entity_id?
      @ent_id  = options.entity_id
      @request = Weblist.EntityRemote.get(options.entity_id)
    @request.done (wl) =>
      @wl = wl
    @setup_event_listening()

  setup_event_listening: () -> 
    pusher = Weblist.EntityPusher.pusher
    channel = pusher.subscribe("entity_channel_#{@ent_id}")
    channel.bind("new_data_event", (wl) => @_swap_wl(wl) )

  _do_action: (action) -> 
    Weblist.EntityRemote.do_action( @ent_id, action ).done (wl) => @_swap_wl(wl)
  
  set: (key, data_item) ->
    @_do_action {verb: "assoc", args: [@_get_keys(key), data_item]}

  delete: (key) ->
    @_do_action {verb: "remove", args: [@_get_keys(key)]}

  add: (data_item) ->
    @insert_at(-1, data_item)

  insert_at: (key, data_item) ->
    @_do_action {verb: "add", args: [@_get_keys(key), data_item]}, @

  move_to: (key, new_key) ->
    @_do_action {verb: "move", args: [@_get_keys(key), new_key]}, @

  get: (key) ->
    Weblist.DataOp.deep_clone(if @wl? then @wl.data[key] else @opt_value()[key])

  opt_value: () -> @wl.data

  changed: (func) -> @change_listeners.push(func)

  _get_keys: (keys) -> if keys instanceof Array then keys else [keys]
  _trigger_change: (wl) -> l(wl.data, wl) for l in @change_listeners

  _swap_wl: (wl) ->
    if !@wl? or @wl._id != wl._id
      @wl = wl
      @_trigger_change(wl)
