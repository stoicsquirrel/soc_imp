module SocImp
  class Photo < ActiveRecord::Base
    has_many :photo_tags
    attr_accessor :url
    attr_accessible :url, :approved, :caption, :file, :image_service, :original_id, :position, :service, :user_full_name, :user_id, :user_screen_name


  end
end
