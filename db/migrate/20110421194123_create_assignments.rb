class CreateAssignments < ActiveRecord::Migration
  def self.up
    create_table :assignments do |t|
      t.integer :group_id, :null => false
      t.integer :user_id,  :null => false
    end

    add_index :assignments, :group_id
    add_index :assignments, :user_id
    add_index :assignments, [:group_id, :user_id]
  end

  def self.down
    drop_table :assignments
  end
end
