class AddIndexToSamples < ActiveRecord::Migration
  def self.up
    add_index :samples, :timestamp
  end

  def self.down
    remove_index :samples, :timestamp
  end
end
