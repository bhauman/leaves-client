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
directory to your web project.

Then link to it in the head of your HTML document or template:

```html
<html>
  <head>
    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.1/jquery.min.js"></script>
    <script src="//your-public-javascripts-dir/leaves-min.js"></script>
  </head>
```

