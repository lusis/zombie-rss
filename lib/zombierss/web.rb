module ZombieRss

  class Web < ::Sinatra::Base
    use ::Rack::Session::Cookie
    module Partials
      def partial( page, variables={} )
        haml page.to_sym, {layout:false}, variables
      end
    end
    helpers Partials

    configure do
      set :static, true
      set :views, File.join(File.expand_path(File.dirname(__FILE__)), "../..", "views")
      set :public_folder, File.join(File.expand_path(File.dirname(__FILE__)), "../..", "public")
      set :show_exceptions, false
    end

    template :layout do
      File.read('views/layout.haml')
    end

    get '/' do
      zombie_feeds = ZombieRss::Feed.all
      sorted_feeds = zombie_feeds.sort {|a,b| a.feed_entries.size <=> b.feed_entries.size}
      haml :home, :format => :html5, :locals => {:feeds => sorted_feeds}
    end

    get '/about' do
      haml :about, :format => :html5
    end

    get '/feeds' do
      zombie_feeds = ZombieRss::Feed.all
      sorted_feeds = zombie_feeds.sort {|a,b| a.feed_entries.size <=> b.feed_entries.size}
      haml :feeds, :format => :html5, :locals => {:feeds => sorted_feeds}
    end

    # All of the stuff below is MVP right now
    # Yes, this needs to be done async
    # Yes, it needs to be DRY'd out
    post '/feed/add/:feed_url/?' do |feed_url|
      begin
        feed_url = CGI.unescape(feed_url)
        feed = ::FeedNormalizer::FeedNormalizer.parse open(feed_url)
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
        end
        haml :_add_feed_success, :format => :html5, :layout => false
      rescue Exception => e
        haml :_add_feed_failure, :format => :html5, :layout => false, :locals => {:error => e.message}
      end
    end

    get '/feed/:feed_id' do |feed_id|
      feed = ZombieRss::Feed.find(feed_id)
      feed_entries = feed.feed_entries.sort {|a,b| b.date_published <=> a.date_published }
      if feed_entries.nil?
        haml :_unknown_feed, :format => :html5
      else
        haml :_feed_content, :format => :html5, :locals => {:feed => feed, :feed_entries => feed_entries}
      end
    end

    post '/feed/:feed_id' do |feed_id|
      feed = ZombieRss::Feed.find(feed_id)
      feed_entries = feed.feed_entries.sort {|a,b| b.date_published <=> a.date_published }
      if feed_entries.nil?
        haml :_unknown_feed, :format => :html5, :layout => false
      else
        haml :_feed_content, :format => :html5, :locals => {:feed => feed, :feed_entries => feed_entries}, :layout => false
      end
    end

    get '/update' do
      feeds = ZombieRss::Feed.all
      feeds.each do |u_feed|
        feed = ::FeedNormalizer::FeedNormalizer.parse open(u_feed.feed_url)

        f = ZombieRss::Feed.find(Digest::SHA1.hexdigest(u_feed.feed_url))

        feed.entries.each do |entry|
          id = entry.id || entry.urls.first
          fe = ZombieRss::Feed.find(Digest::SHA1.hexdigest(id)) || ZombieRss::FeedEntry.new(:authors => entry.authors, :categories => entry.categories, :content => entry.content, :date_published => entry.date_published, :title => entry.title, :urls => entry.urls, :entry_url => id)
          f.feed_entries << fe
          f.save
        end
      end
      redirect '/feeds'
    end
   
  end

end
