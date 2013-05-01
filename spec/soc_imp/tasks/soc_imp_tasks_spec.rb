require 'spec_helper'
require 'rake'

load File.join(Rails.root, 'Rakefile')

describe "soc_imp rake tasks" do
  before do
    SocImp.config do |config|
      config.search_terms = ['#squirrel', '#grumpycat']
      # config.fog_provider = :local
    end

    SocImp::Importers::PhotoImporter.stub(:import) do |search_term|
      puts search_term
    end
  end

#  after do
#    # Delete all uploaded or saved files.
#    connection = SocImp::Importers::PhotoImporter.create_fog_connection
#    directory = connection.directories.get(SocImp::Config.fog_directory)
#    SocImp::Photo.all.each do |photo|
#      base_file_name = File.basename(photo.file)
#      file = directory.files.new(key: base_file_name)
#      file.destroy
#    end
#  end

  describe "soc_imp:photos:import" do
    a = nil
    it "imports photos for each search term specified in the config file" do
      VCR.use_cassette(:all_posts_by_tag_with_photos) do
        Rake::Task['soc_imp:photos:import'].invoke
      end
    end

    # expect(SocImp::Importers::PhotoImporter).to
  end
end