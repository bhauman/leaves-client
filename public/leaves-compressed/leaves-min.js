var DocManager,JsonDoc,PathProxy,TimeView;window.Leaves||(window.Leaves={}),Leaves.root_domain="http://scratch.leaves.io",Leaves.create=function(t){return $.ajax(Leaves.root_domain+"/json-doc",{data:JSON.stringify(t||{}),contentType:"text/plain",type:"POST"})},Leaves.add=function(t,e,n){return $.ajax(Leaves.root_domain+("/json-doc/"+t+"/addable/data-path/"+e.join("/")),{data:JSON.stringify(n),contentType:"text/plain",type:"POST"})},Leaves.assoc=function(t,e,n){return $.ajax(Leaves.root_domain+("/json-doc/"+t+"/settable/data-path/"+e.join("/")),{data:JSON.stringify(n),contentType:"text/plain",type:"POST"})},Leaves.move=function(t,e,n){return $.ajax(Leaves.root_domain+("/json-doc/"+t+"/movable/data-path/"+e.join("/")),{data:JSON.stringify(n),contentType:"text/plain",type:"POST"})},Leaves.remove=function(t,e){return $.ajax(Leaves.root_domain+("/json-doc/"+t+"/deletable/data-path/"+e.join("/")),{contentType:"text/plain",type:"DELETE"})},Leaves.get=function(t){return $.ajax(Leaves.root_domain+("/json-doc/"+t),{type:"GET"})},Leaves.get_with_data=function(t){return $.ajax(Leaves.root_domain+("/json-doc/"+t+"?with_data=true"),{type:"GET"})},Leaves.get_data_path=function(t){return $.ajax(Leaves.root_domain+("/json-doc/"+t+"/data-path/"+path.join("/")),{type:"GET"})},Leaves.get_as_of=function(t,e){return $.ajax(Leaves.root_domain+("/json-doc/"+t+"/time-traveler/as-of/"+e),{type:"GET"})},Leaves.get_since=function(t,e){return $.ajax(Leaves.root_domain+("/json-doc/"+t+"/time-traveler/since/"+e),{type:"GET"})},Leaves.do_action=function(t,e){var n;return n=e.args.slice(0),n.unshift(t),Leaves[e.verb].apply(Leaves,n)},Leaves.opt_action=function(t,e){var n;return n=e.args.slice(0),n.unshift(Leaves.JsonOp.deep_clone(t)),Leaves.JsonOp[""+e.verb+"_node"].apply(Leaves,n)},Leaves.log=function(t){return console.log(t.data)},window.Leaves.JsonDoc=JsonDoc=function(){function t(t){var e=this;null==t&&(t={}),null!=t.webmap_id?this.request=Leaves.get_with_data(t.webmap_id):null!=t.initial_data?this.request=Leaves.create(t.initial_data):null==t.action?this.request=Leaves.create([]):(this.action=t.action,this.previous=t.previous,this.request=this.previous.request.pipe(function(t){return Leaves.do_action(t._id,e.action)})),this.request.done(function(t){return e.wl=t})}return t.prototype._get_keys=function(t){return t instanceof Array?t:[t]},t.prototype.set=function(t,e){return Leaves.JsonDoc.from_action({verb:"assoc",args:[this._get_keys(t),e]},this)},t.prototype["delete"]=function(t){return Leaves.JsonDoc.from_action({verb:"remove",args:[this._get_keys(t)]},this)},t.prototype.add=function(t){return this.insert_at(-1,t)},t.prototype.insert_at=function(t,e){return Leaves.JsonDoc.from_action({verb:"add",args:[this._get_keys(t),e]},this)},t.prototype.move_to=function(t,e){return Leaves.JsonDoc.from_action({verb:"move",args:[this._get_keys(t),e]},this)},t.prototype.get=function(t){return Leaves.JsonOp.deep_clone(null!=this.wl?this.wl.data[t]:this.opt_value()[t])},t.prototype.opt_value=function(){return null==this.action?this.wl&&null!=this.wl.data&&this.wl.data||[]:Leaves.opt_action(this.previous.opt_value(),this.action)},t.prototype.value=function(t){return this.request.done(t)},t.prototype.rejected=function(){return"rejected"===this.request.state()},t.prototype.completed=function(){return"resolved"===this.request.state()},t.prototype.rejected_in_chain=function(){return null==this.action?!1:this.completed()?!1:this.rejected()||this.previous.rejected_in_chain()},t.prototype.last_not_rejected=function(){return this.rejected_in_chain()?this.previous.last_not_rejected():this},t}(),window.Leaves.JsonDoc.from_identifier=function(t){return new JsonDoc({webmap_id:t})},window.Leaves.JsonDoc.from_data=function(t){return new JsonDoc({initial_data:t})},window.Leaves.JsonDoc.from_action=function(t,e){return new JsonDoc({action:t,previous:e})},window.Leaves.DocManager=DocManager=function(){function t(t){var e=this;null==t&&(t={}),this.next_pointer_cache={},this.change_listeners=[],this.opt_change_listeners=[],this.lpointer=new JsonDoc(t),this.lpointer.request.done(function(t){return e._trigger_change(t)})}return t.prototype.add=function(t){return this._swap_pointer(this.lpointer.add(t))&&this},t.prototype.set=function(t,e){return this._swap_pointer(this.lpointer.set(t,e))&&this},t.prototype["delete"]=function(t){return this._swap_pointer(this.lpointer["delete"](t))&&this},t.prototype.insert_at=function(t,e){return this._swap_pointer(this.lpointer.insert_at(t,e))&&this},t.prototype.move_to=function(t,e){return this._swap_pointer(this.lpointer.move_to(t,e))&&this},t.prototype.get=function(t){return this.lpointer.get(t)},t.prototype.opt_value=function(){return this.lpointer.opt_value()},t.prototype.value=function(t){return this.lpointer.value(t)},t.prototype.path=function(t){return new Leaves.PathProxy(t,this)},t.prototype.undo=function(){var t,e=this;return null!=this.lpointer.previous?(this.next_pointer_cache[this.lpointer.previous.wl._id]=this.lpointer,this._swap_pointer(this.lpointer.previous)):null!=this.lpointer.wl["parent-id"]?(t=new JsonDoc({webmap_id:this.lpointer.wl["parent-id"]}),t.request.done(function(){return e.next_pointer_cache[t.wl._id]=e.lpointer,e._swap_pointer(t)})):void 0},t.prototype.redo=function(){var t;return t=this.next_pointer_cache[this.lpointer.wl._id],null!=t?this._swap_pointer(t):void 0},t.prototype.changed=function(t){return this.change_listeners.push(t)},t.prototype.optimistic_changed=function(t){return this.opt_change_listeners.push(t)},t.prototype._swap_pointer=function(t){var e=this;return this._trigger_opt_change(t.opt_value()),t.request.done(function(t){return e._trigger_change(t)}),t.request.fail(function(){return e.lpointer.rejected_in_chain()?e._swap_pointer(e.lpointer.last_not_rejected()):void 0}),this.lpointer=t},t.prototype._trigger_change=function(t){var e,n,i,o,r;for(o=this.change_listeners,r=[],n=0,i=o.length;i>n;n++)e=o[n],r.push(e(t.data,t));return r},t.prototype._trigger_opt_change=function(t){var e,n,i,o,r;for(o=this.opt_change_listeners,r=[],n=0,i=o.length;i>n;n++)e=o[n],r.push(e(t));return r},t}(),window.Leaves.DocManager.from_identifier=function(t){return new DocManager({webmap_id:t})},window.Leaves.DocManager.from_data=function(t){return new DocManager({initial_data:t})},window.Leaves.DocManager.from_cookie=function(t,e){var n,i;return i=Cookies.get(t),n=null!=i?Leaves.DocManager.from_identifier(i):Leaves.DocManager.from_data(e),console.log(n),n.changed(function(e,n){return Cookies.set(t,n._id,{expires:2592e4})}),n},window.Leaves.PathProxy=PathProxy=function(){function t(){}return t.prototype.contructor=function(t,e){return this.parent=e,this.path=t},t.prototype.add=function(t){return this.parent.insert_at(this.path.concat([-1]),t)&&this},t.prototype.set=function(t,e){return this.parent.set(this.path.concat([t]),e)&&this},t.prototype["delete"]=function(t){return this.parent["delete"](this.path.concat([t]))&&this},t.prototype.insert_at=function(t,e){return this.parent.insert_at(this.path.concat([t]),e)&&this},t.prototype.move_to=function(t,e){return this.parent.move_to(this.path.concat([t]),e)&&this},t}(),window.Leaves.TimeView=TimeView=function(){function t(t,e,n){null==n&&(n="get_as_of"),this.original_wl=t,this.change_listeners=[],this.func_name=n,this.travel(e)}return t.prototype.changed=function(t){return this.change_listeners.push(t)},t.prototype._trigger_change=function(t){var e,n,i,o,r;for(o=this.change_listeners,r=[],n=0,i=o.length;i>n;n++)e=o[n],r.push(e(t.data,t));return r},t.prototype.value=function(t){return this.request.done(function(e){return t(e.data)})},t.prototype.travel=function(t){var e=this;return this.request=Leaves[this.func_name](this.original_wl._id,t),this.request.done(function(t){return e._trigger_change(t)})},t}(),window.Leaves.as_of_view=function(t,e){return new Leaves.TimeView(t,e,"get_as_of")},window.Leaves.since_view=function(t,e){return new Leaves.TimeView(t,e,"get_since")};var _base;window.Leaves||(window.Leaves={}),(_base=window.Leaves).JsonOp||(_base.JsonOp={}),function(t){return t.apply_to_node=function(e,n,i){var o;return o=n[0],e=e||("number"==typeof o?[]:{}),null==o?i(e):(e[o]=t.apply_to_node(e[o],n.slice(1),i),e)},t.insert_into_array=function(t,e,n){return-1===e?t.push(n):t.splice(e,0,n),t},t.insert_at=function(e,n,i){if(null==e&&"number"==typeof n)return t.insert_at([],n,i);if(null==e)return t.insert_at({},n,i);if(e instanceof Array)return t.insert_into_array(e,n,i);if("object"==typeof e)return e[n]=i,e;throw"must be either array or object or nil"},t.remove_from_vec=function(t,e){return t.slice(0,e).concat(t.slice(e+1))},t.remove_at=function(e,n){return null==e?null:e instanceof Array?t.remove_from_vec(e,n):"object"==typeof e?(delete e[n],e):e},t.move_to=function(e,n,i){var o,r;return r=e[n],o=t.remove_at(e,n),t.insert_at(o,i,r)},t.assoc_node=function(e,n,i){return 0===n.length?i:t.apply_to_node(e,n.slice(0,-1),function(t){return t[n.slice(-1)[0]]=i,t})},t.add_node=function(e,n,i){return t.apply_to_node(e,n.slice(0,-1),function(e){return t.insert_at(e,n.slice(-1)[0],i)})},t.remove_node=function(e,n){return t.apply_to_node(e,n.slice(0,-1),function(e){return t.remove_at(e,n.slice(-1)[0])})},t.move_node=function(e,n,i){return t.apply_to_node(e,n.slice(0,-1),function(e){return t.move_to(e,n.slice(-1)[0],i)})},t.deep_clone=function(t){return $.extend(!0,{},{data:t}).data}}(Leaves.JsonOp);var Entity,LiveEntity;window.Weblist||(window.Weblist={}),window.Weblist.EntityRemote={},Weblist.EntityPusher={},Weblist.EntityPusher.setup=function(t){return Weblist.EntityPusher.pusher=new Pusher(t)},Weblist.EntityRemote.create=function(t){return $.ajax("/entity",{data:JSON.stringify(t||{}),contentType:"application/json",type:"POST"})},Weblist.EntityRemote.create_from_wl_id=function(t){return $.ajax("/entity/from-ref/"+t,{contentType:"application/json",type:"POST"})},Weblist.EntityRemote.add=function(t,e,n){return $.ajax("/entity/"+t+"/"+e.join("/")+"?op=add",{data:JSON.stringify(n),contentType:"application/json",type:"POST"})},Weblist.EntityRemote.assoc=function(t,e,n){return $.ajax("/entity/"+t+"/"+e.join("/"),{data:JSON.stringify(n),contentType:"application/json",type:"POST"})},Weblist.EntityRemote.remove=function(t,e){return $.ajax("/entity/"+t+"/"+e.join("/"),{contentType:"application/json",type:"DELETE"})},Weblist.EntityRemote.move=function(t,e,n){return $.ajax("/entity/"+t+"/"+e.join("/")+"?op=move",{data:JSON.stringify(n),contentType:"application/json",type:"POST"})},Weblist.EntityRemote.get=function(t){return $.ajax("/entity/"+t,{type:"GET"})},Weblist.EntityRemote.do_action=function(t,e){var n;return n=e.args.slice(0),n.unshift(t),Weblist.EntityRemote[e.verb].apply(Weblist,n)},window.Weblist.Entity=Entity=function(){function t(t){var e=this;null==t&&(t={}),this.change_listeners=[],null!=t.entity_id&&(this.ent_id=t.entity_id,this.request=Weblist.EntityRemote.get(t.entity_id)),this.request.done(function(t){return e.wl=t})}return t.prototype.add=function(t){var e=this;return this.request=Weblist.EntityRemote.add(this.ent_id,[-1],t),this.request.done(function(t){return e._swap_wl(t)})},t.prototype.value=function(t){return this.request.done(t)},t.prototype.changed=function(t){return this.change_listeners.push(t)},t.prototype._trigger_change=function(t){var e,n,i,o,r;for(o=this.change_listeners,r=[],n=0,i=o.length;i>n;n++)e=o[n],r.push(e(t.data,t));return r},t.prototype._swap_wl=function(t){return this.wl=t,this._trigger_change(t)},t}(),window.Weblist.LiveEntity=LiveEntity=function(){function t(t){var e=this;null==t&&(t={}),this.change_listeners=[],null!=t.entity_id&&(this.ent_id=t.entity_id,this.request=Weblist.EntityRemote.get(t.entity_id)),this.request.done(function(t){return e.wl=t}),this.setup_event_listening()}return t.prototype.setup_event_listening=function(){var t,e,n=this;return e=Weblist.EntityPusher.pusher,t=e.subscribe("entity_channel_"+this.ent_id),t.bind("new_data_event",function(t){return n._swap_wl(t)})},t.prototype._do_action=function(t){var e=this;return Weblist.EntityRemote.do_action(this.ent_id,t).done(function(t){return e._swap_wl(t)})},t.prototype.set=function(t,e){return this._do_action({verb:"assoc",args:[this._get_keys(t),e]})},t.prototype["delete"]=function(t){return this._do_action({verb:"remove",args:[this._get_keys(t)]})},t.prototype.add=function(t){return this.insert_at(-1,t)},t.prototype.insert_at=function(t,e){return this._do_action({verb:"add",args:[this._get_keys(t),e]},this)},t.prototype.move_to=function(t,e){return this._do_action({verb:"move",args:[this._get_keys(t),e]},this)},t.prototype.get=function(t){return Weblist.DataOp.deep_clone(null!=this.wl?this.wl.data[t]:this.opt_value()[t])},t.prototype.opt_value=function(){return this.wl.data},t.prototype.changed=function(t){return this.change_listeners.push(t)},t.prototype._get_keys=function(t){return t instanceof Array?t:[t]},t.prototype._trigger_change=function(t){var e,n,i,o,r;for(o=this.change_listeners,r=[],n=0,i=o.length;i>n;n++)e=o[n],r.push(e(t.data,t));return r},t.prototype._swap_wl=function(t){return null==this.wl||this.wl._id!==t._id?(this.wl=t,this._trigger_change(t)):void 0},t}();