class RemovePostUrlFromPhoto < ActiveRecord::Migration
  def up
    remove_column :soc_imp_photos, :post_url
    add_column :soc_imp_photos, :original_id, :string, null: false
    change_column :soc_imp_photos, :post_id, :string, null: true
  end

  def down
    add_column :soc_imp_photos, :post_url, :string
    remove_column :soc_imp_photos, :original_id
    change_column :soc_imp_photos, :post_id, :string, null: false
  end
end
