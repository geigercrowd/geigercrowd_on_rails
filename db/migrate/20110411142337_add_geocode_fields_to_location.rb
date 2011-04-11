class AddGeocodeFieldsToLocation < ActiveRecord::Migration
  def self.up
    add_column :locations, :country, :string
    add_column :locations, :city, :string
    add_column :locations, :province, :string
  end

  def self.down
    remove_column :locations, :country, :string
    remove_column :locations, :city, :string
    remove_column :locations, :province, :string
  end
end
