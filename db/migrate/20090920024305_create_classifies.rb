class CreateClassifies < ActiveRecord::Migration
  def self.up
    create_table :classifies do |t|
      t.column :remark_id, :int, :null => false
      t.column :word, :string, :null => false
      t.column :delete_flag, :tinyint, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :classifies
  end
end
