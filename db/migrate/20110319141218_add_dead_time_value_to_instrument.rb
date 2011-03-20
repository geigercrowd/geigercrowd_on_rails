class AddDeadTimeValueToInstrument < ActiveRecord::Migration
  def self.up
    add_column :instruments, :deadtime, :integer
  end

  def self.down
    remove_column :instruments, :deadtime
  end
end
