require 'fog'

# TODO: Tumblr tag search should go into more pages?

module SocImp
  module Importers
    module PhotoImporter
      def self.create_twitter_connection
        Twitter.configure do |config|
          config.consumer_key = SocImp::Config.twitter_consumer_key
          config.consumer_secret = SocImp::Config.twitter_consumer_secret
          config.oauth_token = SocImp::Config.twitter_oauth_token
          config.oauth_token_secret = SocImp::Config.twitter_oauth_token_secret
        end
      end

      def self.create_instagram_connection
        Instagram.configure do |config|
          config.client_id = SocImp::Config.instagram_client_id
        end
      end

      def self.create_tumblr_connection
        Tumblr.configure do |config|
          config.consumer_key = SocImp::Config.tumblr_consumer_key
          config.consumer_secret = SocImp::Config.tumblr_consumer_secret
        end

        @tumblr_client ||= Tumblr::Client.new
      end

      def self.create_fog_connection
        case SocImp::Config.fog_provider
        when :aws
          @aws_fog_connection ||= Fog::Storage.new({
            provider: SocImp::Config.fog_provider,
            aws_access_key_id: SocImp::Config.aws_access_key_id,
            aws_secret_access_key: SocImp::Config.aws_secret_access_key
          })
          @fog_connection = @aws_fog_connection
        else
          @local_fog_connection ||= Fog::Storage.new({
            provider: SocImp::Config.fog_provider,
            local_root: SocImp::Config.local_root,
            endpoint: SocImp::Config.local_endpoint
          })
          @fog_connection = @local_fog_connection
        end
        @fog_connection
      end

      def self.import(q)
        import_from_twitter(q)

        if q.start_with? '@'
          search_type = :name
        elsif q.start_with? '#'
          search_type = :tag
          import_by_tag_from_instagram(q.gsub('#', ''))
          import_by_tag_from_tumblr(q.gsub('#', ''))
        end
      end

      def self.import_from_twitter(q)
        require 'twitter'
        create_fog_connection
        create_twitter_connection

        retry_attempts = 0
        begin
          results = Twitter.search("#{q}", include_entities: true, count: 100).results
        # If Twitter is over capacity, unavailable, or can't be reached, then
        # wait five seconds and try again until retry attempts are exhausted.
        rescue Twitter::Error::ServiceUnavailable, Twitter::Error::ClientError
          if retry_attempts < SocImp::Config.connection_retry_attempts
            retry_attempts += 1
            sleep 5
            retry
          # If we've exhausted all retry attempts, then stop and raise original error.
          else
            raise
          end
        end

        save_photos_from_twitter_feed(results)
      end

      def self.import_by_tag_from_instagram(tag)
        require 'instagram'
        create_fog_connection
        create_instagram_connection

        results = Instagram.tag_recent_media(tag)
        results.each do |item|
          photo = nil

          if !Photo.where(original_id: item.id).exists?
            photo = Photo.new(
              caption: item.caption.text,
              user_screen_name: item.user.username,
              user_full_name: item.user.full_name,
              user_id: item.user.id,
              service: 'instagram',
              original_id: item.id,
              url: item.images.standard_resolution.url
            )
            item.tags.each do |tag|
              photo.photo_tags << PhotoTag.new(text: tag, original: true)
            end
          end

          download_and_save_photo(photo) unless photo.nil?
        end
      end

      def self.import_by_tag_from_tumblr(tag)
        require 'tumblr_client'
        create_fog_connection
        create_tumblr_connection

        results = @tumblr_client.tagged(tag) #, format: "text")

        results.each do |item|
          if item["photos"].any? && !Photo.where(original_id: item["id"].to_s).exists?
            item["photos"].each do |photo_item|
              photo = Photo.new(
                caption: item["caption"],
                user_screen_name: item["blog_name"],
                service: 'tumblr',
                original_id: item["id"].to_s,
                url: photo_item["original_size"]["url"]
              )
              item["tags"].each do |tag|
                photo.photo_tags << PhotoTag.new(text: tag, original: true)
              end

              download_and_save_photo(photo) unless photo.nil?
            end
          end
        end
      end

      def self.save_photos_from_twitter_feed(feed_items)
        feed_items.each do |item|
          # Check if there are any included images (hosted by Twitter),
          # then import those.
          photo = nil

          if item.media.any?
            item.media.each do |media|
              # Create a photo object if the media type is "photo", and the photo
              # object does not exist in the database.
              if media.class == Twitter::Media::Photo && !Photo.where(original_id: media.id.to_s).exists?
                photo = Photo.new(
                  caption: item.text,
                  user_screen_name: item.from_user,
                  user_full_name: item.from_user_name,
                  user_id: item.from_user_id,
                  service: 'twitter',
                  image_service: 'twitter',
                  original_id: media.id.to_s,
                  url: media.media_url
                )
                item.hashtags.each do |hashtag|
                  photo.photo_tags << PhotoTag.new(text: hashtag.text, original: true)
                end
              end

              download_and_save_photo(photo) unless photo.nil?
            end
          # If there are no included images, then check if there are any images
          # hosted on other services such as Twitpic, YFrog, etc.
#          elsif item.urls.any?
#            item.urls.each do |url|
#              photo_url = !url.expanded_url.blank? ? url.expanded_url : url.url
#              photo = twitter_external_photo(photo_url)
#
#              # If we found a photo, then save it
#              unless photo.nil?
#                # attrs = {
#                #   photo_id: photo[:id],
#                #   caption: item.text,
#                #   from_user_username: item.from_user,
#                #   from_user_full_name: item.from_user_name,
#                #   from_user_id: item.from_user_id,
#                #   twitter_image_service: photo[:twitter_image_service]
#                # }
#                # download_and_save_photo(:twitter, photo[:url], attrs)
#
#
#              end
#            end
          end
        end
      end

      protected

      def self.download_and_save_photo(photo)
        file = download_file(photo)

        photo.file = store_file(file).public_url
        photo.save
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
        if match.nil?
          begin
            conn = Faraday.new(url: photo_url) do |faraday|
              faraday.request :url_encoded
            end
            expanded_photo_url = conn.get(photo_url).response_headers['location']
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
            unless @tumblr_consumer_key.blank?
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

      def self.download_file(photo)
        response = Faraday.get(photo.url)
        file = nil

        if response.status == 200
          # Get the type of image file. There may not be an extension, so let's look at the mime type.
          case response.headers['content-type']
          when "image/jpeg"
            ext = ".jpg"
          when "image/png"
            ext = ".png"
          when "image/gif"
            ext = ".gif"
          end

          # Make a temporary image file and save it if the file is correct.
          # Make the temp directory if one doesn't exist
          filename = "#{SecureRandom.urlsafe_base64(11)}#{ext}"
          d = Date.today
          dir = "#{Rails.root}/tmp/images/#{d.year}/#{d.month}/#{d.day}"
          FileUtils.mkdir_p(dir)
          file = File.open("#{dir}/#{filename}", "w") do |file|
            file.binmode # File must be opened in binary mode

            # Save the file
            file << response.body
          end
        end

        return file.path unless file.nil?
      end

      def self.store_file(file_name)
        File.open(file_name) do |file|
          # Get the fog directory (bucket).
          directory = @fog_connection.directories.get(SocImp::Config.fog_directory)
          # If the fog directory does not exist, create it if allowed by config.
          if directory.nil? && SocImp::Config.auto_create_fog_directory
            directory = @fog_connection.directories.create(
              key: SocImp::Config.fog_directory,
              public: true
            )
          end

          # Upload the file contents.
          fog_file = directory.files.create(
            key: File.basename(file_name),
            body: file,
            public: true
          )
          fog_file
        end
      end

      def self.require_if_installed(gem_name)
        result = false
        if Gem::Specification.find_all_by_name(gem_name).any?
          require gem_name
          result = true
        end
        result
      end
    end
  end
end