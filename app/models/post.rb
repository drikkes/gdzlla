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
      tags: ['gdzlla']
    }
  end

  field :message,             type: String
  field :source,              type: String
  field :short_id,            type: String
  field :flickr_data,         type: Hash
  field :tweet_data,          type: Hash
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
    if user.strip_tags
      title = message.sub(/( #[^\s]+ ?)*$/, '')
    else
      title = message.gsub(tag_pattern, '<a href="http://twitter.com/search?q=%23\1">#\1</a>')
    end
    title.gsub(username_pattern, '<a href="http://twitter.com/\1">@\1</a>')
  end

  def description

  end

  def tags
    message.scan(tag_pattern) + self.defaults[:tags]
  end

  def url
    "#{self.url_choices[user.url_type]}#{short_id}"
  end

  def flickr_url

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

  def post_to_flickr
    debugger
    user.flickr_client.uploader.upload
  end

  def generate_short_id
    self.short_id = Base58.encode(flickr_data[:id])
  end

  def get_tweet_data

  end

end