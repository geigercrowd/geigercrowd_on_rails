class CreateSamples < ActiveRecord::Migration
  def self.up
    create_table :samples do |t|
      t.float :value
      t.integer :data_type_id
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end

  def self.down
    drop_table :samples
  end
end
