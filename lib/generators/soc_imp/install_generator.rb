module SocImp
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../../templates', __FILE__)

      desc "Creates a SocImp initializer."

      def copy_initializer
        template "soc_imp.rb", "config/initializers/soc_imp.rb"
      end
    end
  end
end
