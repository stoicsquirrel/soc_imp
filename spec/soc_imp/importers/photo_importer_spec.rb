require 'spec_helper'

describe SocImp::Importers::PhotoImporter do
  describe "description" do
    it "imports photos from tagged tweets on Twitter" do
      #VCR.use_cassette('twitter_photos') do
        SocImp::Importers::PhotoImporter.import_by_tag("minecraft")
      #end
    end
  end
end