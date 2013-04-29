require 'spec_helper'

describe SocImp::Importers::PhotoImporter do
  before do
    # Test uploading files on local file system only, except where specified.
    SocImp.config do |c|
      c.fog_provider = :local
    end
  end

  describe ".import" do

  end

  describe ".import_from_twitter" do
    let(:search_term) { "#grumpycat" }

    let(:twitter_results) do
      VCR.use_cassette('twitter_tweets_by_tag_with_photos') do
        Twitter.search("#{search_term}", include_entities: true, count: 100).results
      end
    end

    let(:twitter_photo_count) do
      ids = []
      count = 0
      twitter_results.each do |item|
        if item.media.any?
          # We need to iterate through all the media in order to check for duplicates.
          # Multiple tweets can reference the same media item.
          item.media.each do |media|
            if media.class == Twitter::Media::Photo && !ids.include?(media.id.to_s)
              ids << media.id.to_s
              count += 1
            end
          end
        end
      end
      count
    end

    let(:one_photo) do
      photo_found = false

      results = []
      VCR.use_cassette('twitter_tweets_short') do
        results = Twitter.search(search_term, include_entities: true, count: 15).results
      end

      results.each do |item|
        # Check if there are any included images (hosted by Twitter),
        # then import those.
        photo = nil

        if item.media.any?
          item.media.each do |media|
            # Create a photo object if the media type is "photo", and the photo
            # object does not exist in the database.
            if media.class == Twitter::Media::Photo
              photo = SocImp::Photo.new(
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
                photo.photo_tags << SocImp::PhotoTag.new(text: hashtag.text, original: true)
              end

              photo_found = true
              break
            end
          end
        end

        break if photo_found
      end

      "http://localhost/one_photo_test.jpg"
    end

    it "imports photos from Twitter" do
      VCR.use_cassette('twitter_tweets_by_tag_with_photos') do
        SocImp::Importers::PhotoImporter.import_from_twitter(search_term)
      end

      expect(SocImp::Photo).to have(twitter_photo_count).photos
    end

    it "imports a photo from Twitter only once" do
      2.times do
        VCR.use_cassette('twitter_tweets_by_tag_with_photos') do
          SocImp::Importers::PhotoImporter.import_from_twitter(search_term)
        end
      end

      expect(SocImp::Photo).to have(twitter_photo_count).photos
    end

    it "creates Photo objects with the correct information" do
      puts one_photo
    end

    it "uploads photos to S3" do
      pending "may not need to test connection to S3"

      # Test uploading files to S3.
      SocImp.config do |c|
        c.fog_provider = :aws
      end

      VCR.use_cassette('twitter_tweets_by_tag_with_photos') do
        SocImp::Importers::PhotoImporter.import_from_twitter(search_term)
      end

      bucket = SocImp::config.fog_directory
      # Take a sample photo and match the final URL with the expected URL on S3.
      expect(SocImp::Photo.first.file).to match(/https?:\/\/#{bucket}\.s3\.amazonaws\.com\/.+/)

      # Delete files uploaded in this test from S3.
      connection = SocImp::Importers::PhotoImporter.create_fog_connection
      directory = connection.directories.get(SocImp::Config.fog_directory)
      SocImp::Photo.all.each do |photo|
        base_file_name = File.basename(photo.file)
        file = directory.files.new(key: base_file_name)
        file.destroy
      end
    end

    context "by user name" do
      let(:search_term) { "@WilliamShatner" }

      let(:twitter_results) do
        VCR.use_cassette('twitter_tweets_by_name_with_photos') do
          Twitter.search("#{search_term}", include_entities: true, count: 100).results
        end
      end

      it "imports photos from Twitter by user name" do
        VCR.use_cassette('twitter_tweets_by_name_with_photos') do
          SocImp::Importers::PhotoImporter.import_from_twitter(search_term)
        end

        expect(SocImp::Photo).to have(twitter_photo_count).photos
      end
    end
  end

  describe ".import_by_tag_from_instagram" do
    let(:tag) { "grumpycat" }

    let(:instagram_results) do
      VCR.use_cassette('instagram_posts_by_tag_with_photos') do
        Instagram.tag_recent_media(tag)
      end
    end

    let(:instagram_photo_count) do
      ids = []
      count = 0
      instagram_results.each do |item|
        if !ids.include?(item.id)
          ids << item.id
          count += 1
        end
      end
      count
    end

    it "imports photos from Instagram by tag" do
      VCR.use_cassette('instagram_posts_by_tag_with_photos') do
        SocImp::Importers::PhotoImporter.import_by_tag_from_instagram(tag)
      end

      expect(SocImp::Photo).to have(instagram_photo_count).photos
    end
  end

  describe ".import_by_tag_from_tumblr" do
    let(:tag) { "grumpycat" }

    let(:tumblr_results) do
      client = Tumblr::Client.new
      VCR.use_cassette('tumblr_posts_by_tag_with_photos') do
        client.tagged(tag)
      end
    end

    let(:tumblr_photo_count) do
      count = 0
      tumblr_results.each do |item|
        count += item["photos"].count
      end
      count
    end

    it "imports photos from Tumblr by tag" do
      VCR.use_cassette('tumblr_posts_by_tag_with_photos') do
        SocImp::Importers::PhotoImporter.import_by_tag_from_tumblr(tag)
      end

      expect(SocImp::Photo).to have(tumblr_photo_count).photos
    end
  end
end