require 'spec_helper'

describe SocImp::Importers::PhotoImporter do
  describe "description" do
    it "imports photos from tagged tweets on Twitter" do
      VCR.use_cassette('twitter_photos') do
        SocImp::Importers::PhotoImporter.import_by_tag("minecraft")
      end

      # Get Twitter::Photo objects using Twitter gem to count expected # of photos.
      expect(SocImp::Photo).to have(6).photos
    end
  end
end