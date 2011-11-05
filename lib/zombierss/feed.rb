module ZombieRss

  class Feed
    include ::Ripple::Document
    self.bucket_name = "feeds"

    property :description,  String
    property :last_updated, Time, :default => proc { Time.now }
    property :authors,      Array
    property :image,        String
    property :url,          String
    property :title,        String
    property :date_added,   Time, :default => proc { Time.now }
    property :feed_url,     String, :presence => true

    many :feed_entries, :class_name => "ZombieRss::FeedEntry"

    def key
      @key ||= Digest::SHA1.hexdigest(feed_url)
    end
  end

end
