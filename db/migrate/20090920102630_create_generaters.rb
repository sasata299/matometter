class CreateGeneraters < ActiveRecord::Migration
  def self.up
    create_table :generaters do |t|
      t.column :user_id, :string, :null => false
      t.column :body, :string, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :generaters
  end
end
