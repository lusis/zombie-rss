module ZombieRss

  class FeedEntry
    include ::Ripple::Document
    self.bucket_name = "feed_entries"

    property  :title, String, :presence => true
    property  :authors, Array
    property  :categories, Array
    property  :content, String
    property  :date_published, String
    property  :description, String
    property  :urls, Array
    property  :entry_url, String, :presence => true
    one       :feed, :class_name => "ZombieRss::Feed"

    def key
      @key ||= Digest::SHA1.hexdigest(entry_url)
    end

  end

end
