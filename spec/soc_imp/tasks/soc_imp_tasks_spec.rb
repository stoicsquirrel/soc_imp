require 'spec_helper'
require 'rake'

describe "soc_imp rake tasks" do
  before do
    # Ensure that rake reloads before each test.
    Rake.application = Rake::Application.new
    load File.join(Rails.root, 'Rakefile')

    # Supress console output from rake tasks.
    $stdout.stub(:write)
    @search_terms = []

    SocImp.config do |config|
      config.search_terms = ['#squirrel', '#grumpycat']
    end

    SocImp::Importers::PhotoImporter.stub(:import) do |search_term|
      @search_terms << search_term
    end

    # SocImp::Importers::PhotoImporter.stub(:import_from_twitter) do |search_term|
    #   @search_terms << search_term
    # end

    # SocImp::Importers::PhotoImporter.stub(:import_from_instagram) do |search_term|
    #   @search_terms << search_term
    # end

    # SocImp::Importers::PhotoImporter.stub(:import_from_tumblr) do |search_term|
    #   @search_terms << search_term
    # end
  end

  after do
    Rake.application = nil
  end

  describe "soc_imp:photos:import" do
    context "when search terms are defined" do
      it "imports photos for each search term specified in the config file" do
        Rake::Task['soc_imp:photos:import'].invoke
        expect(SocImp::Config.search_terms).to eq(@search_terms)
      end
    end

    context "when search terms are not defined" do
      it "will fail" do
        SocImp.config do |config|
          config.search_terms = []
        end

        expect {
          Rake::Task['soc_imp:photos:import'].invoke
        }.to raise_error("No search terms defined. Define search terms in config/initializers/soc_imp.rb.")
      end
    end
  end

  # describe "soc_imp:photos:import_from_twitter" do
  #   a = nil
  #   it "imports photos for each search term specified in the config file" do
  #     Rake::Task['soc_imp:photos:import_from_twitter'].invoke
  #     expect(SocImp::Config.search_terms).to eq(@search_terms)
  #   end
  # end

  # describe "soc_imp:photos:import_from_instagram" do
  #   a = nil
  #   it "imports photos for each search term specified in the config file" do
  #     Rake::Task['soc_imp:photos:import_from_instagram'].invoke
  #     expect(SocImp::Config.search_terms).to eq(@search_terms)
  #   end
  # end

  # describe "soc_imp:photos:import_from_tumblr" do
  #   a = nil
  #   it "imports photos for each search term specified in the config file" do
  #     Rake::Task['soc_imp:photos:import_from_tumblr'].invoke
  #     expect(SocImp::Config.search_terms).to eq(@search_terms)
  #   end
  # end
end