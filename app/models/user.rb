class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :login,             type: String
  field :url_type,          type: Symbol
  field :photoset,          type: String
  field :flickr_token,      type: String
  field :twitter_pin,       type: String
  field :twitter_rtoken,    type: String
  field :twitter_rsecret,   type: String

  has_many :posts

  index login: 1

  def to_param
    login
  end


end