class AddTimestampToSamples < ActiveRecord::Migration
  def self.up
    add_column :samples, :timestamp, :datetime
  end

  def self.down
    remove_column :samples, :timestamp
  end
end
