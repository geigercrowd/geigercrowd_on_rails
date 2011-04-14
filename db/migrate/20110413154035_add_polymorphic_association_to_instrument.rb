class AddPolymorphicAssociationToInstrument < ActiveRecord::Migration
  def self.up
    add_column :instruments, :origin_id, :integer
    add_column :instruments, :origin_type, :string
    remove_column :instruments, :user_id
    add_index :instruments, :origin_id
  end

  def self.down
    renmove_column :instruments, :origin_id, :integer
    renmove_column :instruments, :origin_type, :string
    add_column :instruments, :user_id
    add_index :instruments, :user_id
  end
end
