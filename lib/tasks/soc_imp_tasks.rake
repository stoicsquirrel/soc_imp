namespace :soc_imp do
  namespace :photos do
    desc "Import photos"
    task :import => :environment do
      puts "Importing photos..."
      SocImp::Config.search_terms.each do |search_term|
        puts "Now searching #{search_term}..."
        SocImp::Importers::PhotoImporter.import(search_term)
      end
    end

    desc "Import photos from Twitter"
    task :import_from_twitter => :environment do
      puts "Importing photos from Twitter..."
      SocImp::Config.search_terms.each do |search_term|
        puts "Now searching #{search_term}..."
        SocImp::Importers::PhotoImporter.import_from_twitter(search_term)
      end
    end
  end
end
