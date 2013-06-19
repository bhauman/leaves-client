root_dir = File.dirname(__FILE__)

task :default do
  "build all files"
  puts "compiling all coffee files"
  puts `coffee -o #{root_dir}/public/leaves -cb #{root_dir}/src`
end

task :watch do
  "watching and building all files in src"
  puts "watching all files in src"
  puts `coffee -o #{root_dir}/public/leaves -cwb #{root_dir}/src`  
end  

task :server do
  "Start server for example apps on port 9292"
  puts "Starting server for example apps"
  puts `rackup`
end

task :clean do
  `rm -rf #{root_dir}/public/leaves`
  `rm #{root_dir}/public/leaves-compressed/leaves.js`
  `rm #{root_dir}/public/leaves-compressed/leaves-min.js`
  `rmdir #{root_dir}/public/leaves-compressed`
end

task :compile => [:default] do
  require 'uglifier'
  `mkdir -p #{root_dir}/public/leaves-compressed`
  `cat #{root_dir}/public/leaves/leaves.js #{root_dir}/public/leaves/leaves/* > #{root_dir}/public/leaves-compressed/leaves.js`
  open("#{root_dir}/public/leaves-compressed/leaves-min.js", 'w') do |f|
    f.write Uglifier.compile File.read("#{root_dir}/public/leaves-compressed/leaves.js")
  end
end
