class AddLocationRelationToSample < ActiveRecord::Migration
  def self.up
      add_column :samples, :location_id, :integer
  end

  def self.down
      remove_column :samples, :location_id, :integer
  end
end
