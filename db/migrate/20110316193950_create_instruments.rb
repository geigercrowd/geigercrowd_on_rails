class CreateInstruments < ActiveRecord::Migration
  def self.up
    create_table :instruments do |t|
      t.integer :data_type_id
      t.integer :user_id
      t.string :model
      t.text :notes
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end

  def self.down
    drop_table :instruments
  end
end
