class CreateEventWorkflow < ActiveRecord::Migration
  def self.up
    create_table :event_workflows do |t|
      t.string :pid
      t.string :state

      t.timestamps
    end

    add_index :event_workflows, :pid
    add_index :event_workflows, :state
  end

  def self.down
    drop_table :event_workflows
  end
end
