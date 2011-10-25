module ZombieRss

  class Feed
    include ::Ripple::Document
    self.bucket_name = "feeds"

    property :id,           String
    property :description,  String
    property :last_updated, Time, :default => proc { Time.now }
    property :authors,      Array
    property :image,        String
    property :url,          String
    property :title,        String

    many :feed_entries, :class_name => "ZombieRss::FeedEntry"

    def key
      @key ||= id
    end
  end

end
