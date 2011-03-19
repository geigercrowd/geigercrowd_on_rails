class AddErrorValueToInstrument < ActiveRecord::Migration
  def self.up
    add_column :instruments, :error, :integer
  end

  def self.down
    remove_column :instruments, :error
  end
end
