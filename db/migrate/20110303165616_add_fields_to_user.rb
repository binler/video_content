class AddFieldsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :first_name,   :string
    add_column :users, :last_name,    :string
    add_column :users, :nickname,     :string
    add_column :users, :account_type, :string
  end

  def self.down
    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :nickname
    remove_column :users, :account_type
  end
end
