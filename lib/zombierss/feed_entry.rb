module ZombieRss

  class FeedEntry
    include ::Ripple::Document
    self.bucket_name = "feed_entries"

    property  :id, String, :presence => true
    property  :title, String, :presence => true
    property  :authors, Array
    property  :categories, Array
    property  :content, String
    property  :date_published, String
    property  :description, String
    property  :urls, Array
    one       :feed, :class_name => "ZombieRss::Feed"

    def key
      @key ||= id
    end

  end

end
