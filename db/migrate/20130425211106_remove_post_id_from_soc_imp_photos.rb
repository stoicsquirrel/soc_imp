class RemovePostIdFromSocImpPhotos < ActiveRecord::Migration
  def up
    remove_column :soc_imp_photos, :post_id
  end

  def down
    add_column :soc_imp_photos, :post_id, :integer
  end
end
