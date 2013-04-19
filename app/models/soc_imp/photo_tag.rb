module SocImp
  class PhotoTag < ActiveRecord::Base
    belongs_to :photo
    attr_accessible :original, :text
  end
end
