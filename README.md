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

### Document Paths

Most operations take a document path.  A document path is simply an
array describing the path to an item in the document. Given the
following document:

```javascript
{ moves_so_far: [2, 5], 
  players: [ { name: "Bonnie", plays_as: "X" }, 
             { name: "Clyde", plays_as: "O" } ] }
```

These document paths refer to the following values:

```javascript
["moves_so_far"]           -> [2, 5] 
["moves_so_far", 0]        -> 2 
["moves_so_far", 1]        -> 5 
["players", 0, "name"]     -> "Bonnie" 
["players", 1, "plays_as"] -> "O"
["players", 1]             -> { name: "Bonnie", plays_as: "X" }
["players"]                -> [ { name: "Bonnie", plays_as: "X" }, 
                                { name: "Clyde", plays_as: "O" } ]
[] -> { moves_so_far: [2, 5], 
        players: [ { name: "Bonnie", plays_as: "X" },         
                   { name: "Clyde", plays_as: "O" } ] }
```

### Operations

The following is a whirlwind tour of the available operations. All of
the following operations are cumulative and based on an initial
document: `{ moves_so_far: []}`

#### Creating the document

```javascript
TTT.game_data = Leaves.DocManager.from_data({ moves_so_far: [] });

/// or with cookie storage
TTT.game_data = Leaves.DocManager.from_cookie('tic_tac_toe', { moves_so_far: [] });
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

TTT.game_data.add(['moves_so_far'], 2);
// -> { moves_so_far: [2], 
//      players: [ { name: "Bonnie", plays_as: "X" }, 
//                 { name: "Clyde", plays_as: "O" } ] }

TTT.game_data.add(['moves_so_far'], 5);
// -> { moves_so_far: [2, 5], 
//      players: [ { name: "Bonnie", plays_as: "X" }, 
//                 { name: "Clyde", plays_as: "O" } ] }
```

#### Deleting things from maps and arrays

```javascript
TTT.game_data.delete(['players']);
// -> { moves_so_far: [2, 5] }

TTT.game_data.delete(['moves_so_far', 1]);
// -> { moves_so_far: [2] }
```

#### Inserting things into an array
```javascript
TTT.game_data.insert_at(['moves_so_far', 1], 8);
// -> { moves_so_far: [2, 8] }

TTT.game_data.insert_at(['moves_so_far', 0], 6);
// -> { moves_so_far: [6, 2, 8] }
```

#### Moving elements in an array
```javascript
TTT.game_data.move_to(['moves_so_far', 0], 2);
// -> { moves_so_far: [2, 8, 6] }

TTT.game_data.move_to(['moves_so_far', 1], 2);
// -> { moves_so_far: [2, 6, 8] }
```

### Examining the current state of things

#### Getting the state of an value at a path

```javascript
TTT.game_data.get(["moves_so_far", 0])
// returns 2
```

#### Getting the optimistic value of the current document

The optimistic value of the current document is the value it should
hold if all pending operations are successfully saved to the server.

```javascript
TTT.game_data.opt_value();
// returns { moves_so_far: [2, 6, 8] }
```

#### Getting the actual snapshot value of the document in this moment

```javascript
TTT.game_data.value(function (snapshot_doc) { 
  console.log(snapshot_doc);
});
// console output: { moves_so_far: [2, 6, 8] }
```

#### Listening for changes

there are two different change listeners right now.  One for
optimistic changes and one for actual server confirmed changes.

Listening for server confirmed changes:

```javascript
TTT.game_data.changed(function (snapshot_doc) { 
  console.log(snapshot_doc);
});

TTT.game_data.add(["moves_so_far"], 7)

// console output: { moves_so_far: [2, 6, 8, 7] }
```

The optimistic change event get triggered immediatly after an
operation and will be triggered with a rolled back document if an
error occurs in the queue of pending operations.

Listening for optimistic changes:

```javascript
TTT.game_data.opt_changed(function (snapshot_doc) { 
  console.log(snapshot_doc);
});

TTT.game_data.add(["moves_so_far"], 3)

// console output: { moves_so_far: [2, 6, 8, 7, 3] }
```

### Undo and redo

One of the real benefits of this service is that if you need to undo
something it is both simple and robust.

```javascript
// This will trigger all changed and opt_changed listeners with the
// reverted document value.
TTT.game_data.undo();

// current document: { moves_so_far: [2, 6, 8, 7] }
```

Redo is just as simple:

```javascript
// This will trigger all changed and opt_changed listeners with the
// reverted document value.
TTT.game_data.redo();

// current document: { moves_so_far: [2, 6, 8, 7, 3] }
```

Redo is a much more transient operation.  Redo data is only recorded
in local memory when you call undo and is only available until you
make a `add, set, insert_at, move_to` or `delete` operation.  When a
data changing operation occurs all redo information is erased.

```javascript
// This will trigger all changed and opt_changed listeners with the
// reverted document value.
TTT.game_data.undo();
TTT.game_data.undo();
TTT.game_data.undo();
TTT.game_data.undo();
// current document: { moves_so_far: [2] }

TTT.game_data.redo();
// current document: { moves_so_far: [2, 6] }

TTT.game_data.add(["moves_so_far"], 3);
// current document: { moves_so_far: [2, 6, 3] }

// nothing happens if you redo now
TTT.game_data.redo();
// current document: { moves_so_far: [2, 6, 3] }
```

## Example Applications

You will find the source code for a couple of example applications in
`src/example_apps`.

The HTML pages to hold these applications is located in
`public/example_apps`.  To run these example applications make sure
you have `ruby` installed and do the following:

```bash
cd leaves-client
bundle install

rake server
```

You should now be able to open your browser and navigate to
`localhost:9292` and see an example application.

#### Running tests 

Make sure you have the web server running and navigate to
`localhost:9292/test`.

#### Building 

Take a look at the Rakefile to get an idea of how to build the
project.  Working on this project requires nodejs for coffescript and
ruby for the build tools and JS minification.

The following rake commands are available:

```bash
-> rake -T

rake           # compile all src .coffee files into the public/leaves dir
rake watch     # watch and compile changed src files
rake server    # Start server for example apps on port 9292

rake clean     # remove compiled and compressed files from public dir
rake compress  # Compress the compiled files to the public/leaves-compressed dir
```


