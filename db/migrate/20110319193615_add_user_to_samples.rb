class AddUserToSamples < ActiveRecord::Migration
  def self.up
    add_column :samples, :user_id, :integer
  end

  def self.down
    remove_column :samples, :user_id
  end
end
