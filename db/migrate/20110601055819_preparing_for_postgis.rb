class PreparingForPostgis < ActiveRecord::Migration
  def self.up
    add_column :locations, :geometry, :point, :srid => 4326, :with_z => false, :null => false
    add_index  :locations, :geometry, :spatial => true
  end

  def self.down
    remove_column :locations, :geometry
  end
end
