use Rack::Static, 
  :urls => ["/js", "/leaves", "leaves-compressed", "/css", "/example_apps"],
  :root => "public"

run lambda { |env|
  uri = env['REQUEST_URI']
  base_dir = 'public/example_apps/'
  file = base_dir + (uri =~ /data\-viewer/ ? 'data-viewer.html' : 'todos_app.html')
  if uri =~ /test/
    file = "public/test/tests.html"
  end
  [
    200, 
    {
      'Content-Type'  => 'text/html', 
      'Cache-Control' => 'public, max-age=86400' 
   },
   File.open(file, File::RDONLY)
  ]
}
