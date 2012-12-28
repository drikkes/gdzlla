class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  def self.tweet_app_urls
    {
      "Twitterrific" => "http://twitterrific.com/",
      "Twitter for mac" => "http://twitter.com/download/",
      "Tweetbot" => "http://tapbots.com/software/tweetbot/"
    }
  end

  def self.url_choices
    {
      gdzlla: 'http://gdzl.la/',
      flickr: 'http://flic.kr/p/'
    }
  end

  def self.tag_pattern
    /(?<=#)[^\s]+/
  end

  def self.username_pattern
    /(?<=@)[a-zA-Z_]+/
  end

  def self.defaults
    {
      title: 'Photo',
      description: 'Uploaded from twitter via <a href="http://gdzl.la">GDZLLA</a>',
      tags: ['gdzlla'],
      is_public: true
    }
  end

  field :message,             type: String
  field :source,              type: String
  field :short_id,            type: String
  field :flickr_data,         type: Hash
  field :tweet_data,          type: Hash
  field :exif_data,           type: Hash
  field :xmp_data,            type: Hash
  field :location,            type: Array
  field :location_name,       type: String
  field :is_updated,          type: Boolean
  field :update_tries,        type: Integer

  attr_accessor :media

  belongs_to :user

  index is_updated: 1
  index update_tries: 1
  index short_id: 1

  before_validation :post_to_flickr
  before_validation :generate_short_id

  def to_param
    short_id
  end

  def title
    if user.strip_tags?
      title = message.sub(/( #[^\s]+ ?)*$/, '')
    else
      title = message.gsub(self.class.tag_pattern, '<a href="http://twitter.com/search?q=%23\1">#\1</a>')
    end
    title.gsub(self.class.username_pattern, '<a href="http://twitter.com/\1">@\1</a>')
  end

  def description
    self.class.defaults[:description]
  end

  def tags
    message.scan(self.class.tag_pattern) + self.class.defaults[:tags]
  end

  def url
    "#{self.class.url_choices[user.url_type]}#{short_id}"
  end

  def flickr_url
    flickr_data[:photopage_url]
  end

  def as_response
    {
      id: short_id,
      text: title,
      url: short_url,
      width: nil,
      height: nil,
      size: nil,
      type: nil,
      timestamp: nil,
      user: {
        id: nil,
        screen_name: self.user.username,
      }
    }
  end

  private

  def extract_metadata
    img = EXIFR::JPEG.new(media.path)
    self.exif_data = img.to_hash.symbolize_keys
    xmp = XMP.parse(img)
    xmp.namespaces.each do |name|
      ns = xmp.send name
      self.xmp_data[name] = {}
      ns.attributes.each do |att|
        self.xmp_data[name][att] = ns.send(att).inspect
      end
    end
    self.xmp_data = xmp_data.symbolize_keys
  end

  def post_to_flickr
    options = self.class.defaults.merge(title: title)
    options [:tags].push tags
    options[:tags] = options[:tags].join(' ')
    uploaded = user.flickr_client.uploader.upload(media.path, options)
    if uploaded.photoid.to_s.blank?
      self.errors[:base] << "Failed to upload to flickr"
    else
      flickr_photo = user.flickr_client.photos.find_by_id(uploaded.photoid.to_s)
      self.flickr_data = flickr_photo.as_json
                                     .reject{|key| key == 'flickr' }
                                     .as_json  #<= omg, I am actually doing this on purpose. flickr-fu seems to implement its own as_json, not a deep conversion.
                                     .symbolize_keys
                                     .merge(photopage_url: flickr_photo.photopage_url.to_s)
                                     .collect{|k,v| v = v.to_s if [:owner, :title].include? k }
    end
  end

  def generate_short_id
    self.short_id = Base58.encode(flickr_data[:id].to_i)
  end

  def get_tweet_data

  end

end