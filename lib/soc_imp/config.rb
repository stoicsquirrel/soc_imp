module SocImp
  module Config
    class << self
      attr_accessor :twitter_consumer_key
      attr_accessor :twitter_consumer_secret
      attr_accessor :twitter_oauth_token
      attr_accessor :twitter_oauth_token_secret

      attr_accessor :instagram_client_id

      attr_accessor :tumblr_consumer_key
      attr_accessor :tumblr_consumer_secret

      attr_accessor :fog_provider
      attr_accessor :fog_directory
      attr_accessor :auto_create_fog_directory
      attr_accessor :aws_access_key_id
      attr_accessor :aws_secret_access_key
      attr_accessor :local_root
      attr_accessor :local_endpoint

      attr_accessor :connection_retry_attempts

      def reset
        # For Twitter variables, the Twitter gem will automatically search
        # for ENV variables if values are nil in config.
        @twitter_consumer_key = nil
        @twitter_consumer_secret = nil
        @twitter_oauth_token = nil
        @twitter_oauth_token_secret = nil

        @instagram_client_id = nil

        @tumblr_consumer_key = nil
        @tumblr_consumer_secret = nil

        @fog_provider = ENV['FOG_PROVIDER']
        @fog_directory = ENV['FOG_DIRECTORY']
        @auto_create_fog_directory = false
        @aws_access_key_id = ENV['AWS_ACCESS_KEY_ID']
        @aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
        @local_root = nil
        @local_endpoint = nil

        @connection_retry_attempts = 3
      end
    end

    self.reset
  end
end