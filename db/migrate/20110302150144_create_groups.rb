class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string  :name
      t.boolean :restricted,    :default => false
      t.boolean :for_cancan,    :default => false
      t.boolean :is_hydra_role, :default => true

      t.timestamps
    end

    add_index :groups, :is_hydra_role
    add_index :groups, :for_cancan
    add_index :groups, :restricted
  end

  def self.down
    drop_table :groups
  end
end
