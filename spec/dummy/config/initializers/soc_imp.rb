SocImp.config do |config|
  config.twitter_consumer_key = 'QQbgU6Z3lMfXLtSqNYpVw'
  config.twitter_consumer_secret = 'RKXo9Rtk5w52Mrik9M1GoG0Rc85UhFD6UOK0aErrLSk'
  config.twitter_oauth_token = '707298103-EMwxfIBUOuSDdmjzNpD28BgingbZQo7M3ukF8iW9'
  config.twitter_oauth_token_secret = 'Ibww354fZqiseVvS6c6v8CTBHg9I8ChN3X1VxxFz2g'

  config.instagram_client_id = 'ea10f8876e7047f68a87ce7029ad7655'

  config.tumblr_consumer_key = "NDFiR3cHIcdgh11SjVO4ZCLK2jA6oMTRjdlFlFED84ta7QKh8q"
  config.tumblr_consumer_secret = "fSzBLT317jGXDJcAG350RK2Xrs071SpHpJlRPBzCdXFuzD7GF7"

  config.fog_provider = :aws
  config.fog_directory = 'soc-imp-test'
  config.aws_access_key_id = "AKIAITADPSWHGYY64TTA"
  config.aws_secret_access_key = "/uIqBFH+x8Aae1cE9yDd/SVYfMvCRA/jr6YDmVk0"
  config.local_root = './spec/dummy/tmp/images/'
  config.local_endpoint = 'http://localhost'

  config.auto_create_fog_directory = true

  # config.connection_retry_attempts = 3
end