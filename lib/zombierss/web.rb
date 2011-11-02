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
      haml :index, :format => :html5, :locals => {:feeds => zombie_feeds, :content_body => 'content_area'}
    end

    get '/test_page' do
      haml :test_page, :format => :html5, :layout => false
    end

    get '/about' do
      haml :about, :format => :html5, :locals => {:feeds => zombie_feeds, :content_body => 'about'}
    end

  end

end
