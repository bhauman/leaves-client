### The Leaves Javascript Client

> Leaves is exploratory and pre alpha.

This is the client for Leaves an experiental immutable JSON document
service.  The primary feature of this service is immutability.  You
can only _store_ and _read_ documents. You can not update them. 

You *can* however operate on the documents but each operation creates
a new document.

This is a javascript client intended to connect to a Leaves.io service
or one which implements the same api.

### Quickstart

To get started clone or download this repository and copy the
`leaves.js` or `leaves-min.js` from the `public/leaves-compressed/`
directory to your web project. You will also need to copy the
`public/js/vendor/cookies.js` file as well. [Or get it here.](//github.com/ScottHamper/Cookies)

Then link to it in the head of your HTML document or template:

```html
<html>
  <head>
    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.1/jquery.min.js"></script>
    <script src="//your-public-javascripts-dir/cookies.js"></script>
    <script src="//your-public-javascripts-dir/leaves-min.js"></script>
  </head>
```

The easiest integration route is to create a json document as follows:

```javascript
YourApp = YourApp || {};

YourApp.todos_json = Leaves.DocManager.from_cookie('org.example.todos_app.todos_list',
                                                   { todos_list: [] });
```

This creates a new JSON document on the scratch.leaves.io web
service or fetches an existing one if there is already a cookie set
for this client.

Now that you have a todos list document you can operate on it.

*Adding* to the end of an array:
```javascript
YourApp.todos_json.add(['todos_list'], { content: "buy milk" });
// -> { todos_list: [ { content: "buy milk" } ] }

YourApp.todos_json.add(['todos_list'], { content: "copy car key" });
// -> { todos_list: [ { content: "buy milk" }, { content: "copy car key" } ] }
```

The first argument to `add` is a path to the node in the JSON document
that you want to add something to. In this case `['todos_list']` is a
path to the todos_list array in this document.

This data is now stored on the service.  If you want to track when
changes are made to the document simply attach a listener:

```javascript
YourApp.todos_json.changed( function(json_document) { 
  // do something awesome with the data
} );
```

### Operations

The following is a whirlwind tour of the available operations. All of
the following operations are cumulative and based on an initial
document: `{ moves_so_far: []}`

#### Creating the document

```javascript
TTT.game_data = Leaves.DocManager.from_data({ moves_so_far: [], players: [] });

/// or with cookie storage
TTT.game_data = Leaves.DocManager.from_cookie('tic_tac_toe', { moves_so_far: [], players: [] });
```

#### Setting a key on the document

```javascript
TTT.game_data.set(['players'], []);
//-> { moves_so_far: [], players: [] }

TTT.game_data.set(['players', 0], { name: "Greg" });
//-> { moves_so_far: [], players: [ {name: "Greg"} ] }

TTT.game_data.set(['players', 0, 'plays_as'], "X");
//-> { moves_so_far: [], players: [ { name: "Greg", plays_as: "X" } ] }
```

#### Adding an element to an array

```javascript
TTT.game_data.add(['players'], { name: "Bob", plays_as: "O" });
// -> { moves_so_far: [], 
//      players: [ { name: "Bonnie", plays_as: "X" }, 
//                 { name: "Clyde", plays_as: "O" } ] }
```




### Document Paths

Todo
