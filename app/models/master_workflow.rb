# MasterWorkflow is an ActiveRecord counterpart to the Master model. There is a 1:1 relationship.
class MasterWorkflow < Workflow

  attr_accessor :state_transition_comments, :from_address

  def self.find_or_create_by_pid(pid)
    existing_workflow = MasterWorkflow.find_by_pid(pid)
    existing_workflow ? existing_workflow : MasterWorkflow.create(:pid => pid)
  end

  # All programmatically significant actions on a Master that should be registered with CanCan.
  def self.permissible_actions
    self.workflow_actions + self.state_event_names
  end

  # CRUD actions that can be performed on a Master -- used with CanCan.
  def self.workflow_actions
    [ :create_master, :edit_master, :edit_archive_master, :destroy_master ]
  end

  # All actions enforced by Hydra::RightsMetadata via Rolemapper
  # Types derived from Hydra::AccessControlsEnforcement
  def self.hydra_roles
    self.show_actions + self.edit_actions
  end

  # Edit actions enforced by Hydra::RightsMetadata via RoleMapper.
  def self.edit_actions
    [ :edit_master ]
  end

  # Read actions enforced by Hydra::RightsMetadata via RoleMapper.
  def self.show_actions
    [ :discover_master, :read_master ]
  end

  def master
    @master ||= lambda {
      Fedora::Repository.register(ActiveFedora.fedora_config[:url], '')
      require_solr
      Master.load_instance(pid)
    }.call
  end
  alias_method :parent, :master

  state_machine :state, :initial => :created do

    event :approve_for_archival do
      transition :created => :archived
    end

    state :created do
      def abilities_affected_by_state_change
        []
      end
    end

    state :archived do
      def abilities_affected_by_state_change
        []
      end
    end
  end
end
