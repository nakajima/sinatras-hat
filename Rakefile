require 'spec/rake/spectask'
require 'rake/classic_namespace'
require 'cucumber/rake/task'
 
task :default => [:spec, :features]
 
desc "Run all specs"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.spec_opts = ['--colour']
end

Cucumber::Rake::Task.new do |c|
  c.cucumber_opts = '--format progress'
end

namespace :sinatra do
  desc "Clone edge Sinatra"
  task :clone do
    vendor_dir = File.join(File.dirname(__FILE__), 'vendor')
    FileUtils.mkdir_p(vendor_dir)
    puts "* cloning git://github.com/rtomayko/sinatra.git"
    system("git clone git://github.com/rtomayko/sinatra.git #{File.expand_path(vendor_dir)}/sinatra")
    puts "* done."
  end
  
  desc "Update edge Sinatra"
  task :pull do
    sinatra_dir = File.join(File.dirname(__FILE__), 'vendor', 'sinatra')
    Task["sinatra:clone"].invoke unless File.exists?(sinatra_dir)
    
    puts "* pulling from git://github.com/rtomayko/sinatra.git"
    system("cd #{File.expand_path(sinatra_dir)} && git pull git://github.com/rtomayko/sinatra.git master")
    puts "* done."
  end 
  
  desc "Install edge Sinatra"
  task :install => :pull do
    sinatra_dir = File.join(File.dirname(__FILE__), 'vendor', 'sinatra')
    Task["sinatra:clone"].invoke unless File.exists?(sinatra_dir)
    puts "* installing edge sinatra"
    system("cd #{File.expand_path(sinatra_dir)} && rake install")
  end
end
