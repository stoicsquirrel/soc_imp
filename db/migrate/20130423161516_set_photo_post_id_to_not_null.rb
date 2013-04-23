class SetPhotoPostIdToNotNull < ActiveRecord::Migration
  def change
    change_column :soc_imp_photos, :post_id, :string, null: false
  end
end
