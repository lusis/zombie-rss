#!/usr/bin/env ruby
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "..", "lib")))
require 'feed-normalizer'
require 'zombierss'

feeds = ZombieRss::Feed.all

feeds.each do |u_feed|
  feed = FeedNormalizer::FeedNormalizer.parse open(u_feed.feed_url)

  f = ZombieRss::Feed.find(Digest::SHA1.hexdigest(u_feed.feed_url))

  feed.entries.each do |entry|
    id = entry.id || entry.urls.first
    fe = ZombieRss::Feed.find(Digest::SHA1.hexdigest(id)) || ZombieRss::FeedEntry.new(:authors => entry.authors, :categories => entry.categories, :content => entry.content, :date_published => entry.date_published, :title => entry.title, :urls => entry.urls, :entry_url => id)
    f.feed_entries << fe
    f.save
    puts "Adding entry: #{entry.title} to feed record - #{fe.entry_url}"
  end
end
