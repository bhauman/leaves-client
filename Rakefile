root_dir = File.dirname(__FILE__)

desc "compile all src .coffee files into the public/leaves dir"
task :default do
  puts "compiling all coffee files"
  puts `coffee -o #{root_dir}/public/leaves -cb #{root_dir}/src`
end

desc "watch and compile changed src files"
task :watch do
  puts "watching all files in src"
  puts `coffee -o #{root_dir}/public/leaves -cwb #{root_dir}/src`  
end  

desc "Start server for example apps on port 9292"
task :server do
  puts "Starting server for example apps"
  puts `rackup`
end

desc "remove compiled and compressed files from public dir"
task :clean do
  `rm -rf #{root_dir}/public/leaves`
  `rm #{root_dir}/public/leaves-compressed/leaves.js`
  `rm #{root_dir}/public/leaves-compressed/leaves-min.js`
  `rmdir #{root_dir}/public/leaves-compressed`
end

desc "Compress the compiled files to the public/leaves-compressed dir"
task :compress => [:default] do
  require 'uglifier'
  `mkdir -p #{root_dir}/public/leaves-compressed`
  `cat #{root_dir}/public/leaves/leaves.js #{root_dir}/public/leaves/leaves/* > #{root_dir}/public/leaves-compressed/leaves.js`
  open("#{root_dir}/public/leaves-compressed/leaves-min.js", 'w') do |f|
    f.write Uglifier.compile File.read("#{root_dir}/public/leaves-compressed/leaves.js")
  end
end
