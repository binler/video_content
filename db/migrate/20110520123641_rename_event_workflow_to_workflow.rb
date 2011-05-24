class RenameEventWorkflowToWorkflow < ActiveRecord::Migration
  def self.up
    remove_index :event_workflows, :pid
    remove_index :event_workflows, :state
    rename_table :event_workflows, :workflows

    add_column   :workflows, :type, :string, :default => 'EventWorkflow'
    add_index    :workflows, :type
    add_index    :workflows, :pid
    add_index    :workflows, :state
  end

  # NOTE the type column is necessary for STI to work.
  # Calling down on this migration is destructive.
  def self.down
    remove_index  :workflows, :pid
    remove_index  :workflows, :state
    remove_index  :workflows, :type
    remove_column :workflows, :type, :string
    rename_table  :workflows, :event_workflows

    add_index :event_workflows, :pid
    add_index :event_workflows, :state
  end
end
