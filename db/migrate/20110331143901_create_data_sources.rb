class CreateDataSources < ActiveRecord::Migration
  def self.up
    create_table :data_sources do |t|
      t.string :name
      t.string :url
      t.string :parser_class
      t.integer :update_interval
      t.integer :instrument_id
      t.text :options
      t.timestamp :fetched_at
      t.timestamps
    end
    add_column :locations, :data_source_id, :integer
    add_index :locations, :data_source_id
    
  end

  def self.down
    drop_table :data_sources
    remove_index :locations, :data_source_id
    remove_column :locations, :data_source_id
  end
end
