require "soc_imp/config"
require "soc_imp/engine"
require "soc_imp/importers"

module SocImp
  def self.config
    if block_given?
      yield SocImp::Config
    else
      SocImp::Config
    end
  end
end
