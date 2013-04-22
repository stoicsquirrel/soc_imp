module SocImp
  module Config
    class << self
      attr_accessor :twitter_consumer_key
      attr_accessor :twitter_consumer_secret
      attr_accessor :twitter_oauth_token
      attr_accessor :twitter_oauth_token_secret
      attr_accessor :facebook_access_token
      attr_accessor :tumblr_consumer_key
      attr_accessor :instagram_client_id
    end
  end
end