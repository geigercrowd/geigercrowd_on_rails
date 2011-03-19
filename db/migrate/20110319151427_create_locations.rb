class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.string :name
      t.float :latitude
      t.float :longitude
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :locations
  end
end
