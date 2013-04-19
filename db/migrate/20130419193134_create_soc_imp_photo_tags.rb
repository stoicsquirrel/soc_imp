class CreateSocImpPhotoTags < ActiveRecord::Migration
  def change
    create_table :soc_imp_photo_tags do |t|
      t.references :photo, null: false
      t.string :text, null: false
      t.boolean :original, null: false, default: true

      t.timestamps
    end
    add_index :soc_imp_photo_tags, :photo_id
  end
end
