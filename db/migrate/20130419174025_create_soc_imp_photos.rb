class CreateSocImpPhotos < ActiveRecord::Migration
  def change
    create_table :soc_imp_photos do |t|
      t.string :file, null: false
      t.text :caption
      t.string :user_screen_name
      t.string :user_full_name
      t.string :user_id
      t.string :service, null: false
      t.string :image_service
      t.string :post_id
      t.string :post_url
      t.boolean :approved, null: false, default: false
      t.integer :position, null: false, default: 0
      t.references :program, null: false

      t.timestamps
    end
    add_index :soc_imp_photos, :program_id
  end
end
