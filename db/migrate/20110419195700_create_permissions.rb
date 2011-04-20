class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.integer :group_id
      t.integer :permissible_id
      t.string  :permissible_type

      t.timestamps
    end

    add_index :permissions, :id
    add_index :permissions, :group_id
    add_index :permissions, :permissible_id
    add_index :permissions, :permissible_type
  end

  def self.down
    drop_table :permissions
  end
end
