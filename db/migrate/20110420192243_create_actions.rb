class CreateActions < ActiveRecord::Migration
  def self.up
    create_table :actions do |t|
      t.string  :name,             :null => false
      t.integer :permissible_id
      t.string  :permissible_type, :null => false

      t.timestamps
    end

    add_index :actions, :id
    add_index :actions, :name
    add_index :actions, :permissible_id
    add_index :actions, :permissible_type
    add_index :actions, [:permissible_id, :permissible_type]
  end

  def self.down
    drop_table :actions
  end
end
