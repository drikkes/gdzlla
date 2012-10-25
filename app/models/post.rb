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

  def self.defaults
    {
      title: 'Photo',
      description: 'Uploaded from twitter via <a href="http://gdzl.la">GDZLLA</a>',
      tags: ['gdzlla']
    }
  end

  field :title,               type: String
  field :short_id,            type: String
  field :flickr_data,         type: Hash
  field :twitter_data,        type: Hash
  field :location,            type: Array
  field :location_name,       type: String
  field :is_updated,          type: Boolean
  field :update_tries,        type: Integer

  belongs_to :user

  index is_updated: 1
  index update_tries: 1
  index short_id: 1

  def to_param
    short_id
  end



end