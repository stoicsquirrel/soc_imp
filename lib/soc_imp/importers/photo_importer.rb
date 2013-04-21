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
        # If Twitter is over capacity, unavailable, or can't be reached,
        # then wait five seconds and try again up to two times.
        rescue Twitter::Error::ServiceUnavailable, Twitter::Error::ClientError
          if retry_attempts < 3
            retry_attempts += 1
            sleep 5
            retry
          # If we've exhausted all retry attempts, then stop and raise original error.            
          else
            raise
          end
        end

        parse_photos_from_twitter_feed(results)
      end

      private

      def self.parse_photos_from_twitter_feed(feed_items)
        puts "parse"
        feed_items.each do |item|
          # Check if there are any included images (hosted by Twitter),
          # then import those.
          if item.media.any?
            item.media.each do |media|
              photo = {
                photo_id: media.id,
                caption: item.text,
                from_user_username: item.from_user,
                from_user_full_name: item.from_user_name,
                from_user_id: item.from_user_id,
                twitter_image_service: :twitter
              }
              # download_and_save_photo(:twitter, media.media_url, photo)
            end
          # If there are no included images, then check if there are any images
          # hosted on other services such as Twitpic, YFrog, etc.
          elsif item.urls.any?
            item.urls.each do |url|
              photo_url = !url.expanded_url.blank? ? url.expanded_url : url.url
              photo = twitter_external_photo(photo_url)
              puts "PHOTO: #{photo}"
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

      # Recursive function to open URLs and search for photos.
      def self.twitter_external_photo(photo_url)
        photo = Hash.new
        twitter_image_service = nil

        # Search expanded URLs for twitpic.com, yfrog.com, etc.
        expressions = {
          twitpic: /^https?\:\/\/twitpic.com\/(?<id>\S+)$/,
          tumblr: /^https?\:\/\/(tmblr.co|\S+\.tumblr.com)\/\S+$/
        }
        expression = /^https?\:\/\/(?<service>tmblr.co|\S+\.tumblr.com|twitpic.com)\/(?<id>\S+)$/
        match = expression.match(photo_url)

        # If there is no match, check if the URL redirects to another, and if it does,
        # call this function again with the redirect URL.
        # If there is no redirect, then the method ends.
        if match.nil?
          begin
            conn = Faraday.new(url: photo_url) do |faraday|
              faraday.request :url_encoded
            end
            expanded_photo_url = conn.get(photo_url).response_headers['location']
            puts expanded_photo_url
            # expanded_photo_url = HTTParty.get(photo_url, follow_redirects: false).headers["location"]
          rescue StandardError # If there is any error, just continue to the next item.
            # If the request times out or we get a bad URL, continue to the next item.
            return nil
          end
          if !expanded_photo_url.nil?
            return twitter_external_photo(URI::encode(expanded_photo_url))
          end
        else
          case match[:service]
          # Pull image from Twitpic
          when 'twitpic.com'
            unless match[:id].blank?
              photo[:id] = match[:id]
              photo[:url] = "http://twitpic.com/show/full/#{photo[:id]}" unless photo[:id].nil?
              photo[:twitter_image_service] = :twitpic
              return photo
            end
          # Pull image from Tumblr
          when 'tumblr.com', 'tmblr.co'
            unless self.tumblr_consumer_key.blank?
              # If this is a tmblr.co URL, then it must be a redirect.
              if (/tmblr\.co/ =~ photo_url) >= 0
                begin
                  tumblr_page_url = URI::encode(HTTParty.get(photo_url, follow_redirects: false).headers["location"])
                rescue StandardError
                  # If the request times out, continue to the next item.
                  return nil
                end
              else
                tumblr_page_url = photo_url
              end
              begin
                expanded_tumblr_page_url = URI::encode(HTTParty.get(tumblr_page_url, follow_redirects: false).headers["location"])
                logger.info "Expanded Tumblr URL: #{expanded_tumblr_page_url}"
              rescue StandardError
                # If the request times out, continue to the next item.
                return nil
              end
              tumblr_page_info = /^https?\:\/\/(?<username>\S+)\.tumblr.com\/post\/(?<page_id>\d+)\/?\S*$/.match(expanded_tumblr_page_url)
              if !tumblr_page_info.nil?
                tumblr_page_id = tumblr_page_info[:page_id]
                tumblr_user_id = tumblr_page_info[:username]
                response = HTTParty.get("https://api.tumblr.com/v2/blog/#{tumblr_user_id}.tumblr.com/posts/photo",
                  query: {api_key: self.tumblr_consumer_key, id: tumblr_page_id})

                # If we get an OK response from the server, then save the photo
                if response.code == 200
                  # If there is a photo in this post, then save it
                  if !response['response']['posts'][0]['photos'].nil?
                    photo[:id] = tumblr_page_id
                    photo[:url] = response['response']['posts'][0]['photos'][0]['original_size']['url']
                    photo[:twitter_image_service] = :tumblr
                    return photo
                  end
                end
              end
            end
          end
        end

        return nil
      end

      def save_imported_photo(service, photo_url, attrs)
        # Save the image only if it doesn't already exist in our database
        if !self.photos.where(original_photo_id: attrs[:photo_id].to_s, from_service: service.to_s).exists?
          # Get the URL of this image and save it, if we get a response from the server
          begin
            response = HTTParty.get(photo_url)
          rescue Timeout::Error
            # Try again once if the request times out, then quit.
            begin
              response = HTTParty.get(photo_url)
            rescue StandardError
              return nil
            end
          rescue StandardError
            return nil
          end
          if response.code == 200
            # Get the type of image file. There may not be an extension, so let's look at the mime type.
            case response.headers['content-type']
            when "image/jpeg"
              ext = ".jpg"
            when "image/png"
              ext = ".png"
            when "image/gif"
              ext = ".gif"
            end
            # Make a temporary image file and save it if the file is good
            FileUtils.mkdir_p("#{Rails.root}/tmp/images/#{service.to_s}") # Make the temp directory if one doesn't exist

            File.open("#{Rails.root}/tmp/images/#{service.to_s}/#{attrs[:photo_id]}#{ext}", "w") do |file|
              file.binmode # File must be opened in binary mode

              # Save the file
              file << response.body

              # Save the photo info
              photo = self.photos.new
              photo.file.store! file
              photo[:from_service] = service.to_s
              photo[:from_twitter_image_service] = attrs[:twitter_image_service]
              photo[:original_photo_id] = attrs[:photo_id]
              photo[:caption] = attrs[:caption]
              photo[:from_user_username] = attrs[:from_user_username]
              photo[:from_user_full_name] = attrs[:from_user_full_name]
              photo[:from_user_id] = attrs[:from_user_id]

              photo.save
            end
          end
        end
      end
    end
  end
end