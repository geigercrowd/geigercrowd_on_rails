class CreateSamples < ActiveRecord::Migration
  def self.up
    create_table :samples do |t|
      t.float :value
      t.integer :data_type_id
      t.integer :location_id

      t.timestamps
    end
  end

  def self.down
    drop_table :samples
  end
end
