window.DataViewer = {}

DataViewer.Router = Backbone.Router.extend

  routes: 
    "view/:id":                "render_id"
    "previous/:id/:parent_id":                "render_previous"
    "next/:id":                "render_next"

  render_previous: (id, parent_id) ->
    DataViewer.next_stack or= []
    DataViewer.next_stack.push id
    @navigate "view/#{parent_id}", trigger: true

  render_next: (id) ->
    DataViewer.next_stack or= []
    DataViewer.next_stack.pop()
    @navigate "view/#{id}", trigger: true

  render_id: (id) ->
    DataViewer.Editing.unfocus()
    DataViewer.data_ref = new Leaves.JsonDoc.from_identifier id
    DataViewer.data_ref.request.done (wl) ->
      DataViewer.focused_data_events.trigger('new_data', wl)

DataViewer.Editing =
  flyout_state: new (Backbone.Model.extend({}))(
      focused_item: null
      top: 0
      left: -3000
      visible: false
  )

  flyout_controls: "<div id='flyout-controls'>
                       <a class='edit' href='javascript:;'><i class='icon icon-edit'></i></a>
                   </div>"

  focus_on_element: (parent_elem) ->
    if @flyout_state.get('editing')
      return
    position = $(parent_elem).offset()
    @flyout_state.set(
      editing: false
      focused_item: parent_elem
      top: position.top
      left: position.left
      visible: true)

  unfocus: () ->
    @flyout_state.set(
      focused_item: null
      visible: false
      editing: false
    )

  display_flyout: () ->
    $('#flyout-controls').css
      top: @flyout_state.get("top") - 8
      left: @flyout_state.get("left") - 30
      opacity: if @flyout_state.get("visible") then 1.0 else 0.0

  get_path_from_el: (el) ->
    (_(el.parentsUntil(".json_renderer")).map( (el) -> _($(el).attr('class').split(' ')).find( (x) ->  x.match(/path_/))).filter((xx) -> xx?).map (r) -> r.split('_').slice(1).join("_")).reverse()

  update_model: (value) ->
    path = @get_path_from_el $(@flyout_state.get('focused_item'))
    DataViewer.data_ref.set(path, value).request.done (wl) ->
      DataViewer.Editing.unfocus()
      DataViewer.router.navigate "view/" + wl._id, {trigger: true}


  display_atom_edit: (atom_el) ->
    value_holder =  $ '.atom_value', atom_el
    value_holder.html "<input class='field_editor' type='text' value='" + value_holder.text() + "'/>"

  display_edit: () ->
    @flyout_state.set editing: true
    if $(@flyout_state.get('focused_item')).hasClass("atom_name")
      @display_atom_edit($(@flyout_state.get('focused_item')).parent(".atom"))

  set_up: (container) ->
    $("body").append @flyout_controls
    $(container).on 'mouseover', '.atom_name', {}, (e) ->
       e.preventDefault()
       DataViewer.Editing.focus_on_element e.target
    $("body").on 'click', '#flyout-controls .edit', {}, (e) ->
      e.preventDefault()
      DataViewer.Editing.display_edit()
    $(container).on 'keypress', '.field_editor', {}, (e) ->
      code = e.keyCode or e.which
      if code == 13
        DataViewer.Editing.update_model($(e.target).val())
    @flyout_state.on "all", (fs) => @display_flyout()

DataViewer.render_nav = (wl) ->
  DataViewer.next_stack or= []
  nav = "" 
  if wl["parent-id"]
    nav += "<a href='previous/#{wl._id}/#{wl["parent-id"]}' class='previous-item route'><i class='icon icon-chevron-left'></i> previous version</a>"
  if next_id = DataViewer.next_stack[DataViewer.next_stack.length - 1]
    nav += "<a href='next/#{next_id}' class='next-item route'>next version <i class='icon icon-chevron-right'></i></a>"
  result = "<div class='nav-row'>" + nav + "</div>"
  result += "<div class='current-item'>
               <span class='item-id'>#{wl._id}</span>
               <span class='item-nav'><a class='scroll-action'><i class='icon icon-arrow-down'></i>changes</a></span>
            </div>"
  result

DataViewer.action_path_to_selector = (action_path) ->
  selector = (_(action_path).map (part) -> ".path_#{part}").join(" > div > ")
  selector.replace(/div > \.path_-1/, ".array_items > div:last-child")  

DataViewer.display_changes = (wl) ->
  selector = DataViewer.action_path_to_selector(wl.action.path)
  $(selector).addClass 'action_taken'
  if wl.action.op == "remove"
    $(selector).addClass 'action_remove'
    $(selector).html "<div class='removed'>removed</div>"

DataViewer.insert_changes = (wl) ->
  items = Leaves.JsonOp.deep_clone wl.data
  if wl.action? and wl.action.op == "remove"
    Leaves.opt_action items, verb: "add", args: [wl.action.path, {"^^meta": "removed"}]
  else
    items

DataViewer.focused_data_events = {};
_.extend(DataViewer.focused_data_events, Backbone.Events);

# hook up events
DataViewer.focused_data_events.on 'new_data', (wl) ->
  $('.item_nav_area').html DataViewer.render_nav(wl)
  items = DataViewer.insert_changes(wl)
  $('.json_area').html JSONRenderer.render_json(items, wl.action.path)
  DataViewer.display_changes(wl)

# initialize
$(".main_container").append("<div class='item_nav_area'></div>")
$(".main_container").append("<div class='json_area'></div>")

DataViewer.Editing.set_up $(".main_container")

$(".main_container").on 'click', 'a.route', {}, (e) ->
  e.preventDefault()
  path = $(e.target).attr('href')
  console.log path 
  DataViewer.router.navigate path, {trigger: true}

$(".main_container").on 'click', '.scroll-action', {}, (e) ->
  e.preventDefault()
  $('html, body').animate({
         scrollTop: $(".action_taken").offset().top - 100
     }, 500);

DataViewer.router  = new DataViewer.Router()
Backbone.history.start pushState: true, root: '/data-viewer/'
