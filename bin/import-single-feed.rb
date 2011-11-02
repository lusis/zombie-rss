#!/usr/bin/env ruby
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "..", "lib")))
require 'feed-normalizer'
require 'zombierss'

feed_url = ARGV[0]


feed = FeedNormalizer::FeedNormalizer.parse open(feed_url)

f = ZombieRss::Feed.find(Digest::SHA1.hexdigest(feed_url)) || ZombieRss::Feed.new
f.url = feed.urls.first
f.title = feed.title
f.description = feed.description
f.feed_url = feed_url
f.save

feed.entries.each do |entry|
  id = entry.id || entry.urls.first
  fe = ZombieRss::Feed.find(Digest::SHA1.hexdigest(id)) || ZombieRss::FeedEntry.new(:authors => entry.authors, :categories => entry.categories, :content => entry.content, :date_published => entry.date_published, :title => entry.title, :urls => entry.urls, :entry_url => id)
  f.feed_entries << fe
  f.save
  puts "Adding entry: #{entry.title} to feed record - #{fe.entry_url}"
end
