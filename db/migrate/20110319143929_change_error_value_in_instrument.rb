class ChangeErrorValueInInstrument < ActiveRecord::Migration
  def self.up
        remove_column :instruments, :error
        remove_column :instruments, :deathtime
        add_column :instruments, :error, :float
        add_column :instruments, :deathtime, :float
  end

  def self.down
        remove_column :instruments, :error
        remove_column :instruments, :deathtime
        add_column :instruments, :error, :integer
        add_column :instruments, :deathtime, :integer
  end
end
