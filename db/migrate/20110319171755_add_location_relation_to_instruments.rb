class AddLocationRelationToInstruments < ActiveRecord::Migration
  def self.up
	add_column :instruments, :location_id, :integer
  end

  def self.down
	remove_column :instruments, :location_id
  end
end
