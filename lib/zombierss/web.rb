module ZombieRss

  class Web < ::Sinatra::Base
    module Partials
      def partial( page, variables={} )
        haml page.to_sym, {layout:false}, variables
      end
    end
    helpers Partials

    zombie_feeds = ZombieRss::Feed.all

    configure do
      set :static, true
      set :views, File.join(File.expand_path(File.dirname(__FILE__)), "../..", "views")
      set :public_folder, File.join(File.expand_path(File.dirname(__FILE__)), "../..", "public")
    end

    template :layout do
      File.read('views/layout.haml')
    end

    get '/' do
      haml :about, :format => :html5
    end

    get '/test_page' do
      haml :test_page, :format => :html5, :layout => false
    end

    get '/about' do
      haml :about, :format => :html5
    end

    get '/feeds' do
      haml :feeds, :format => :html5, :locals => {:feeds => zombie_feeds}
    end

    post '/feed' do
      feed_entires = ZombieRss::Feed.find(params[:feed_id]).feed_entries
      if feed_entries.nil?
        haml :_unknown_feed, :format => :html5, :layout => false
      else
        haml :_feed_content, :format => :html5, :locals => {:feed_entries => feed_entries}, :layout => false
      end
    end

  end

end
