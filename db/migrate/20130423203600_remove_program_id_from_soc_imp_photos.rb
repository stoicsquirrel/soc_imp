class RemoveProgramIdFromSocImpPhotos < ActiveRecord::Migration
  def up
    remove_column :soc_imp_photos, :program_id
  end

  def down
    add_column :soc_imp_photos, :program_id, :integer
  end
end
