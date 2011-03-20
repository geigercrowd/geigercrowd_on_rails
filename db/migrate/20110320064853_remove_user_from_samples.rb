class RemoveUserFromSamples < ActiveRecord::Migration
  def self.up
    remove_column :samples, :user_id
  end

  def self.down
    add_column :samples, :user_id, :integer
  end
end
