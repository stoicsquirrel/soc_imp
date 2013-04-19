module SocImp
  class Photo < ActiveRecord::Base
    belongs_to :program
    has_many :photo_tags
    attr_accessible :approved, :caption, :file, :image_service, :original_id, :position, :service, :user_full_name, :user_id, :user_name
  end
end
