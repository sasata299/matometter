class AddDeleteFlagToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :delete_flag, :boolean, :default => 0
  end

  def self.down 
    remove_column :users, :delete_flag
  end
end
