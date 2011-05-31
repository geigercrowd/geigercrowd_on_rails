class AddIndexToLocations < ActiveRecord::Migration
  def self.up
    add_index :locations, [ :latitude, :longitude ]
  end

  def self.down
    remove_index :locations, [ :latitude, :longitude ]
  end
end
