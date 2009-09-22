class CreateDictionaries < ActiveRecord::Migration
  def self.up
    create_table :dictionaries do |t|
      t.column :word, :string, :null => false
      t.column :word_type, :string, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :dictionaries
  end
end
