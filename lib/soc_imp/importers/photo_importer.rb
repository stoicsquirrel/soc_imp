module SocImp
  module Importers
    module PhotoImporter
      def self.import_by_tag(tag)
        import_by_tag_from_twitter(tag)
      end

      def self.import_by_tag_from_twitter(tag)
        Twitter.configure do |config|
          config.consumer_key = 'a0CwBDOfP3OAigOeLamiCA'
          config.consumer_secret = 'SHdGnNvE107ehMRUzNXTQkTBLdF8RbXu5m3sjMDwfQ'
          config.oauth_token = '707298103-EMwxfIBUOuSDdmjzNpD28BgingbZQo7M3ukF8iW9'
          config.oauth_token_secret = 'Ibww354fZqiseVvS6c6v8CTBHg9I8ChN3X1VxxFz2g'
        end

        retry_attempts = 0
        begin
          results = Twitter.search("##{tag}", include_entities: true, count: 100).results
        rescue Twitter::Error::ServiceUnavailable, Twitter::Error::ClientError
          # If Twitter is over capacity, unavailable, or can't be reached,
          # then wait five seconds and try again up to two times.
          if retry_attempts < 3
            retry_attempts += 1
            sleep 5
            retry
          else
            # If we've exhausted all retry attempts, then stop and raise original error.
            raise
          end
        end

        parse_twitter_feed_for_photos(results)
      end

      private

      def self.parse_twitter_feed_for_photos(feed_items)
        puts "parse"
        feed_items.each do |item|
          # Check if there are any included images (hosted by Twitter),
          # then import those.
          if item.media.any?
            item.media.each do |media|
              attrs = {
                photo_id: media.id,
                caption: item.text,
                from_user_username: item.from_user,
                from_user_full_name: item.from_user_name,
                from_user_id: item.from_user_id,
                twitter_image_service: :twitter
              }
              # download_and_save_photo(:twitter, media.media_url, attrs)
            end
          # If there are no included images, then check if there are any images
          # hosted on other services such as Twitpic, YFrog, etc.
          elsif item.urls.any?
            item.urls.each do |url|
              expanded_url = !url.expanded_url.blank? ? url.expanded_url : url.url
              # photo = import_photo(expanded_url)
              puts "Downloading..."

              # If we found a photo, then save it
            #  unless photo.nil?
            #    attrs = {
            #      photo_id: photo[:id],
            #      caption: item.text,
            #      from_user_username: item.from_user,
            #      from_user_full_name: item.from_user_name,
            #      from_user_id: item.from_user_id,
            #      twitter_image_service: photo[:twitter_image_service]
            #    }
            #    # download_and_save_photo(:twitter, photo[:url], attrs)
            #  end
            end
          end
        end
      end
    end
  end
end