SocImp.config do |c|
  c.twitter_consumer_key = 'QQbgU6Z3lMfXLtSqNYpVw'
  c.twitter_consumer_secret = 'RKXo9Rtk5w52Mrik9M1GoG0Rc85UhFD6UOK0aErrLSk'
  c.twitter_oauth_token = '707298103-EMwxfIBUOuSDdmjzNpD28BgingbZQo7M3ukF8iW9'
  c.twitter_oauth_token_secret = 'Ibww354fZqiseVvS6c6v8CTBHg9I8ChN3X1VxxFz2g'

  c.instagram_client_id = 'ea10f8876e7047f68a87ce7029ad7655'

  c.tumblr_consumer_key = "NDFiR3cHIcdgh11SjVO4ZCLK2jA6oMTRjdlFlFED84ta7QKh8q"
  c.tumblr_consumer_secret = "fSzBLT317jGXDJcAG350RK2Xrs071SpHpJlRPBzCdXFuzD7GF7"

  c.fog_provider = :aws
  c.fog_directory = 'soc-imp-test'
  c.aws_access_key_id = "AKIAITADPSWHGYY64TTA"
  c.aws_secret_access_key = "/uIqBFH+x8Aae1cE9yDd/SVYfMvCRA/jr6YDmVk0"
  c.local_root = './spec/dummy/tmp/images/'
  c.local_endpoint = 'http://localhost'

  c.auto_create_fog_directory = true

  # c.connection_retry_attempts = 3
end