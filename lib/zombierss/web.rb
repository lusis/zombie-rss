module ZombieRss

  class Web < ::Sinatra::Base

    configure do
      set :static, true
      set :views, File.join(File.expand_path(File.dirname(__FILE__)), "../..", "views")
      set :public_folder, File.join(File.expand_path(File.dirname(__FILE__)), "../..", "public")
    end

    template :layout do
      File.read('views/layout.haml')
    end

    get '/' do
      feeds = ZombieRss::Feed.all
      haml :index, :format => :html5, :locals => {:feeds => feeds}
    end

    get '/feed/:feed_id/?' do
      
    end
  end

end
