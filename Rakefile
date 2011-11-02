$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "lib")))
require "bundler/gem_tasks"
require "zombierss"

desc "Clean data from Riak"
task :purge do
  puts "Purging Feed Entries"
  ZombieRss::FeedEntry.all.each {|f| f.destroy}
  puts "Purging Feeds"
  ZombieRss::Feed.all.each {|f| f.destroy}
end
