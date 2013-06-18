window.TodosApp = {}

TodosApp.todo_form_template = _.template '<form class="new_todo_form"><input name="content" type="text" placeholder="New todo item"/></form>'
TodosApp.list_form_template = _.template '<form class="new_todo_list_form">
                                             <input name="content" type="text" placeholder="New todo list name"/>
                                              <p>
                                                <input type="submit" href="javascript:;" class="btn btn-primary"value="Save">
                                                <a href="javascript:;" class="cancel-action btn">Cancel</a>
                                              </p>
                                          </form>'

TodosApp.todo_lists_template = (lists, focused_index) ->
  lists = (_.pairs(lists).map (parts) ->
    [index, {name: name}] = parts
    klass = if parseInt(index) == focused_index then "active" else ""
    "<li class='#{klass}'><a href='javascript:;' class='focus-list-action' data-index='#{index}' style='padding-left:1em;'>#{name}</a></li>").join('')
  "<ul class='nav nav-pills'>" + lists + "</ul>"

TodosApp.render_todos = (todos) ->
  controls = '<a href="javascript:;" class="remove-action"><i class="icon-remove"></i></a>'
  controls = controls + '<a href="javascript:;" class="complete-action"><i class="icon-ok"></i></a>'
  rtodos = (_.pairs(todos).map (index_todo) ->
    [index, todo] = index_todo
    style = if todo.completed? then "text-decoration:line-through" else ""
    "<li data-index='#{ index }' style='#{style}'>#{controls} #{ todo.content }</li>").join("")
  "<ul class='unstyled'>" + rtodos + "</ul>"

TodosApp.render_lists_view_area = (data, view_state) ->
  if view_state.state == "adding_new_list"
    TodosApp.list_form_template()
  else
    TodosApp.todo_lists_template(data.lists, data.focused_list)

TodosApp.render_todos_area = (data, view_state) ->
  todo_list = data.lists[data.focused_list || 0]
  if todo_list? and view_state.state == "normal"
    """<p class="lead">#{todo_list.name}
         <a href="javascript:;" class="remove-list-action" style="position:relative; top: 5px; padding-left: 16px">
           <i class='icon-trash'></i>
         </a>
       </p>
    """ + TodosApp.render_todos(todo_list.todo_items) + TodosApp.todo_form_template()
  else
    ""

TodosApp.render = (data, view_state) ->
  $(".container .lists_view_area").html TodosApp.render_lists_view_area(data, view_state)
  $(".container .todos_area").html TodosApp.render_todos_area(data, view_state)
  focus_form = if view_state.state == "adding_new_list" then ".new_todo_list_form" else ".new_todo_form"
  $(focus_form + " input[type=text]").focus()

# data actions
TodosApp.add_new_list = (name) ->
  data = TodosApp.data
  data.insert_at(['lists', -1], {name: name, todo_items: []})
  data.set("focused_list", data.get('lists').length - 1)

#action listeners

$('body').on 'click', '.new-list-action', {}, (e) ->
  e.preventDefault()
  TodosApp.view_state.state = "adding_new_list"
  TodosApp.render(TodosApp.data.opt_value(), TodosApp.view_state)

$('body').on 'click', '.undo-action', {}, (e) ->
  e.preventDefault()
  TodosApp.data.undo()

$('body').on 'click', '.redo-action', {}, (e) ->
  e.preventDefault()
  TodosApp.data.redo()

$('body').on 'click', '.view-data-action', {}, (e) ->
  e.preventDefault()
  location.href = "/data-viewer/view/" + TodosApp.data.lpointer.wl._id

$('.main_container').on 'click', '.cancel-action', {}, (e) ->
  e.preventDefault()
  TodosApp.view_state.state = "normal"
  TodosApp.render(TodosApp.data.opt_value(), TodosApp.view_state)

$('.main_container').on 'click', '.focus-list-action', {}, (e) ->
  e.preventDefault()
  TodosApp.data.set('focused_list', parseInt($(e.target).attr('data-index')))

$('.main_container').on 'click', '.complete-action', {}, (e) ->
  e.preventDefault()
  item_index =  parseInt($(e.target).parentsUntil('ul').last().attr('data-index'))
  focus_list_index = TodosApp.data.get("focused_list") || 0
  TodosApp.data.set ["lists", focus_list_index, "todo_items", item_index, "completed"], true

$('.main_container').on 'click', '.remove-action', {}, (e) ->
  e.preventDefault()
  item_index =  parseInt($(e.target).parentsUntil('ul').last().attr('data-index'))
  focus_list_index = TodosApp.data.get("focused_list") || 0
  TodosApp.data.delete ["lists", focus_list_index, "todo_items", item_index]

$('.main_container').on 'click', '.remove-list-action', {}, (e) ->
  e.preventDefault()
  focus_list_index = TodosApp.data.get("focused_list") || 0
  TodosApp.data.set('focused_list', 0)
  TodosApp.data.delete ["lists", focus_list_index]

$('.main_container').on 'submit', '.new_todo_list_form', {}, (e) ->
  e.preventDefault()
  TodosApp.view_state.state = "normal"
  TodosApp.add_new_list($('.new_todo_list_form input').val())

$('.main_container').on 'submit', '.new_todo_form', {}, (e) ->
  e.preventDefault()
  focus_list_index = TodosApp.data.get("focused_list") || 0
  TodosApp.data.insert_at ["lists", focus_list_index, "todo_items", -1], { content: $('.new_todo_form input').val() }

#page setup
TodosApp.view_state = { state: "normal" }

TodosApp.data = Leaves.DocManager.from_cookie('todos_app2_v6', { lists: []})
# TodosApp.data = new Weblist.LiveEntity entity_id: "51af401203641e1e2697aebd"

TodosApp.data.changed (data) ->
  TodosApp.render data, TodosApp.view_state

TodosApp.data.lpointer.request.done (wl) ->
  TodosApp.render wl.data, TodosApp.view_state

#TodosApp.data.changed (data) ->
#  TodosApp.render data, TodosApp.view_state

$("body").prepend """<div class="navbar navbar-static-top">
                            <div class="navbar-inner">
                              <div class="container">
                              <a class="brand" href="javascript:;">Todos</a>
                              <ul class="nav">
                                <li><a class='new-list-action' href='javascript:;'><i class='icon-list'></i> add list</a></li>
                                <li><a class='undo-action' href='javascript:;'><i class='icon-step-backward'></i> undo</a></li>
                                <li><a class='redo-action' href='javascript:;'><i class='icon-step-forward'></i> redo</a></li>
                                <li><a class='view-data-action' href='javascript:;'><i class='icon-eye-open'></i> view data</a></li>
                              </ul>
                              </div>
                            </div>
                          </div>"""

$(".main_container").append '<div class="lists_view_area"></div>'
$(".main_container").append '<div class="todos_area"></div>'
