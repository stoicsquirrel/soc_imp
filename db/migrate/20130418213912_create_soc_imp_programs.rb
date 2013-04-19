class CreateSocImpPrograms < ActiveRecord::Migration
  def change
    create_table :soc_imp_programs do |t|
      t.string :name
      t.boolean :import_active
      t.string :facebook_access_token
      t.string :instagram_client_id
      t.string :tumblr_consumer_key
      t.datetime :last_imported_at

      t.timestamps
    end
  end
end
