task :default do
  "build all files"
  puts "compiling all files"
  puts `coffee -o public/leaves -cb src`
end

task :watch do
  "watching and building all files in src"
  puts "watching all files in src"
  puts `coffee -o public/leaves -cwb src`
end  

task :server do
  "Start server for example apps on port 9292"
  puts "Starting server for example apps"
  puts `rackup`
end

task :clean do
  `rm -rf ./public/leaves`
  `rm public/leaves-compressed/leaves.js`
  `rm public/leaves-compressed/leaves-min.js`
  `rmdir public/leaves-compressed`
end

task :compile => [:default] do
  require 'uglifier'
  `mkdir -p public/leaves-compressed`
  `cat public/leaves/leaves.js public/leaves/leaves/* > public/leaves-compressed/leaves.js`
  open('public/leaves-compressed/leaves-min.js', 'w') do |f|
    f.write Uglifier.compile File.read("public/leaves-compressed/leaves.js")
  end
end
