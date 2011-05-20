class RenameEventWorkflowToWorkflow < ActiveRecord::Migration
  def self.up
    rename_table :event_workflows, :workflows
    remove_index :event_workflows, :pid
    remove_index :event_workflows, :state

    add_column   :workflows, :type, :string, :default => 'EventWorkflow'
    add_index    :workflows, :type
  end

  # NOTE the type column is necessary for STI to work.
  # Calling down on this migration is destructive.
  def self.down
    rename_table  :workflows, :event_workflows
    remove_column :workflows, :type, :string
    remove_index  :workflows, :type

    add_index :event_workflows, :pid
    add_index :event_workflows, :state
  end
end
