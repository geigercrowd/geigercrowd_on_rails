class RemoveLatitudeLongtitudeFromInstrument < ActiveRecord::Migration
  def self.up
	remove_column :instruments, :latitude
	remove_column :instruments, :longitude
  end

  def self.down
	column_add :instruments, :latitude, :float
	column_add :instruments, :longitude, :float
  end
end
