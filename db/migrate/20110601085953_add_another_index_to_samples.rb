class AddAnotherIndexToSamples < ActiveRecord::Migration
  def self.up
    add_index :samples, [ :timestamp, :instrument_id ]
  end

  def self.down
    remove_index :samples, [ :timestamp, :instrument_id ]
  end
end
