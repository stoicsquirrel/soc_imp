SocImp.config do |config|
  # config.search_terms = []

  # config.twitter_consumer_key = ''
  # config.twitter_consumer_secret = ''
  # config.twitter_oauth_token = ''
  # config.twitter_oauth_token_secret = ''

  # config.instagram_client_id = ''

  # config.tumblr_consumer_key = ''
  # config.tumblr_consumer_secret = ''

  # Currently supports :localhost and :aws
  config.fog_provider = :localhost
  # config.fog_directory = ''
  # config.aws_access_key_id = ''
  # config.aws_secret_access_key = ''
  config.local_root = './tmp/soc_imp/assets/'
  config.local_endpoint = 'http://localhost'
  # config.auto_create_fog_directory = true

  # config.connection_retry_attempts = 3
end