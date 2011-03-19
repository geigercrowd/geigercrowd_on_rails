class RemoveLatitudeLongtitudeFromSample < ActiveRecord::Migration
  def self.up
	remove_column :samples, :latitude
	remove_column :samples, :longitude
  end

  def self.down
	add_column :samples, :latitude, :float
 	add_column :samples, :longitude, :float
  end
end
