### The Leaves Javascript client

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
`public/js/vendor/cookies.js` file as well. [see cookies here](//github.com/ScottHamper/Cookies)

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



