window.TodosApp = {}

TodosApp.data = Weblist.ListManager.from_cookie('todos_app_v4', [])

TodosApp.Util = {}

TodosApp.Util.uuid = ->
  'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
    r = Math.random()*16|0
    v = if c == 'x' then r else (r&0x3|0x8)
    v.toString(16)

TodosApp.Util.index_of_id = (list, id) -> _(list).pluck("id").indexOf(id)

TodosApp.update_item = (id, merge_hash) ->
  index = TodosApp.Util.index_of_id TodosApp.data.opt_value(), id
  TodosApp.data.set( index, _.extend(TodosApp.data.get(index), merge_hash) )

TodosApp.remove_item = (id, merge_hash) ->
  index = TodosApp.Util.index_of_id TodosApp.data.opt_value(), id
  TodosApp.data.delete( index )

TodosApp.form_template = _.template '<form class="new_todo_form"><input name="content" type="text"/></form>'

TodosApp.render_todos = (todos) ->
  controls = '<a href="javascript:;" class="remove-action"><i class="icon-trash"></i></a>'
  controls = controls + '<a href="javascript:;" class="complete-action"><i class="icon-ok"></i></a>'
  (_(todos).map (todo) ->
    style = if todo.completed? then "text-decoration:line-through" else ""
    "<li id='#{ todo.id }' style='#{style}'>#{controls} #{ todo.content }</li>").join("")

TodosApp.rerender = (todos) ->
  $("#todos-list").html TodosApp.render_todos(todos)
  $(".new_todo_form").replaceWith TodosApp.form_template
  $(".new_todo_form input").focus()

TodosApp.data.changed TodosApp.rerender

$('.container').on 'click', '.complete-action', {}, (e) ->
  e.preventDefault()
  item_id =  $(e.target).parentsUntil('ul').last().attr('id')
  TodosApp.update_item item_id, completed: true

$('.container').on 'click', '.remove-action', {}, (e) ->
  e.preventDefault()
  item_id =  $(e.target).parentsUntil('ul').last().attr('id')
  TodosApp.remove_item item_id

$('.container').on 'click', '.undo-action', {}, (e) ->
  e.preventDefault()
  TodosApp.data.undo()

$('.container').on 'click', '.redo-action', {}, (e) ->
  e.preventDefault()
  TodosApp.data.redo()

$('.container').on 'submit', '.new_todo_form', {}, (e) ->
  e.preventDefault()
  TodosApp.data.add {id: TodosApp.Util.uuid(), content: $('.new_todo_form input').val()}

$('.container').append """
                       <div id="controls-list">
                         <a href="javascript:;" class="undo-action"><i class="icon-step-backward"></i></a>
                         <a href="javascript:;" class="redo-action"><i class="icon-step-forward"></i></a>
                       </div>
                       """

$('.container').append('<ul id="todos-list" style="list-style:none; margin-left:0px"></ul>')
$('.container').append(TodosApp.form_template())
