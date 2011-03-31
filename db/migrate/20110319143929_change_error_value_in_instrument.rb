class ChangeErrorValueInInstrument < ActiveRecord::Migration
  def self.up
        remove_column :instruments, :error
        remove_column :instruments, :deadtime
        add_column :instruments, :error, :float
        add_column :instruments, :deadtime, :float
  end

  def self.down
        remove_column :instruments, :error
        remove_column :instruments, :deadtime
        add_column :instruments, :error, :integer
        add_column :instruments, :deadtime, :integer
  end
end
