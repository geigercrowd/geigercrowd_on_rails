class RemoveLatLngColumnsFromLocation < ActiveRecord::Migration
  def self.up
    remove_index :locations, [ :latitude, :longitude ]
    remove_column :locations, :latitude
    remove_column :locations, :longitude
  end

  def self.down
    add_column :locations, :latitude, :float
    add_column :locations, :longitude, :float
    add_index :locations, [ :latitude, :longitude ]
  end
end
