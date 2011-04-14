class AddShortNameToDataSource < ActiveRecord::Migration
  def self.up
    add_column :data_sources, :short_name, :string
    add_index :data_sources, :short_name
  end

  def self.down
    remove_index :data_sources, :short_name
    remove_column :data_sources, :short_name
  end
end
