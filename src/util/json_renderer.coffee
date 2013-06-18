JSONRenderer =
  render_json: (json) ->
    result = @render_json_helper(json)
    "<div class='json_renderer'>#{result}</div>"

  render_json_helper: (json) ->
    result = if json instanceof Array
      items = (_.pairs(json).map (pair) => @render_pair pair[0], pair[1])
      items_rend = if items.length == 0 then "<span class='empty'>empty</span>" else _(items).join("")
      "<div class='array_items'>
          #{ items_rend }
       </div>"
    else if !json?
      "<span class='null_val'>null</span>"
    else if typeof json == "object"
      items = (_.pairs(json).map (pair) => @render_pair pair[0], pair[1]).join("")
      items_rend = if items.length == 0 then "<span class='empty'>empty</span>" else _(items).join("")
      "<div class='hash_items'>
         #{ items_rend }
       </div>"
    else
      "#{json}"

  render_pair: (key, value) ->
    if value instanceof Array
      "<div class='array path_#{key}'><div class='array_name'>#{key} :</div>#{ @render_json_helper value }</div>"
    else if typeof value == "object"
      "<div class='hash path_#{key}'><div class='object_name'>#{key} :</div>#{ @render_json_helper value }</div>"
    else
      "<div class='atom path_#{key}'><span class='atom_name'>#{key} :</span><span class='atom_value'>#{ @render_json_helper value }</span></div>"

