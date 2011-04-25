class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.integer :action_id, :null => false
      t.integer :group_id,  :null => false

      t.timestamps
    end

    add_index :permissions, :action_id
    add_index :permissions, :group_id
    add_index :permissions, [:action_id, :group_id]
  end

  def self.down
    drop_table :permissions
  end
end
