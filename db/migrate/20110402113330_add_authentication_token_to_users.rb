class AddAuthenticationTokenToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :authentication_token, :string
    add_index :users, :authentication_token
  end

  def self.down
    remove_index :user, :authentication_token
    remove_column :users, :authentication_token
  end
end
