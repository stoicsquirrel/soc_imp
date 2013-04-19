class AddTwitterAuthFieldsToProgram < ActiveRecord::Migration
  def change
    add_column :soc_imp_programs, :twitter_consumer_key, :string
    add_column :soc_imp_programs, :twitter_consumer_secret, :string
    add_column :soc_imp_programs, :twitter_oauth_token, :string
    add_column :soc_imp_programs, :twitter_oauth_token_secret, :string
  end
end
