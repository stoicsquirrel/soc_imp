module SocImp
  class Program < ActiveRecord::Base
    has_many :photos
    attr_accessible :twitter_consumer_key, :twitter_consumer_secret, :twitter_oauth_token, :twitter_oauth_token_secret, :facebook_access_token, :import_active, :instagram_client_id, :last_imported_at, :name, :tumblr_consumer_key
  end
end
