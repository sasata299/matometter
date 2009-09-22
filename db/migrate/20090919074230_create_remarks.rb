class CreateRemarks < ActiveRecord::Migration
  def self.up
    create_table :remarks do |t|
      t.column :user_id, :string, :null => false
      t.column :remark, :string, :null => false
      t.column :wakati, :string, :null => false
      t.column :delete_flag, :tinyint, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :remarks
  end
end
