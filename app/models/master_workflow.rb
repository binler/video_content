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

  def master_created_callback
    ApplicationMailer.deliver_master_created_notice(SMTP_DEBUG_EMAIL_ADDRESS) if Rails.env =~ /^dev/
  end

  def master_ready_for_derivative_video_editors_callback
    opts = {}
    opts.merge!(:master_id=>master.master_id) unless master.nil? || master.master_id.nil?
    opts.merge!(:event_id=>master.parent.composite_id) unless master.nil? || master.parent.nil? || master.parent.composite_id.nil?
    opts.merge!(:master_pid=>master.pid) unless master.nil? || master.pid.nil?
    opts.merge!(:comments=>state_transition_comments) unless state_transition_comments.nil?
    opts.merge!(:from_address=>from_address) unless from_address.nil?
    to_users = get_to_users
    to_users << from_address unless from_address.nil?
    ApplicationMailer.deliver_master_video_captured_notice(to_users.uniq.join(","),opts)
    true
  end

  def master_notify_video_editors_of_updates_callback
    opts = {}
    opts.merge!(:master_id=>master.master_id) unless master.nil? || master.master_id.nil?
    opts.merge!(:event_id=>master.parent.composite_id) unless master.nil? || master.parent.nil? || master.parent.composite_id.nil?
    opts.merge!(:master_pid=>master.pid) unless master.nil? || master.pid.nil?
    opts.merge!(:comments=>state_transition_comments) unless state_transition_comments.nil?
    opts.merge!(:from_address=>from_address) unless from_address.nil?
    to_users = get_to_users
    to_users << from_address unless from_address.nil?
    ApplicationMailer.deliver_master_video_updated_notice(to_users.uniq.join(","),opts)
    true
  end

  def master_notify_archive_review_callback
    opts = {}
    opts.merge!(:master_id=>master.master_id) unless master.nil? || master.master_id.nil?
    opts.merge!(:event_id=>master.parent.composite_id) unless master.nil? || master.parent.nil? || master.parent.composite_id.nil?
    opts.merge!(:master_pid=>master.pid) unless master.nil? || master.pid.nil?
    opts.merge!(:comments=>state_transition_comments) unless state_transition_comments.nil?
    opts.merge!(:from_address=>from_address) unless from_address.nil?
    to_users = get_to_users
    to_users = to_users | get_group_users(event.owner.first) unless event.owner.empty?
    to_users << from_address unless from_address.nil?
    ApplicationMailer.deliver_master_archive_review_notice(to_users.uniq.join(","),opts)
    true
  end

  def master_notify_archived_callback
    opts = {}
    opts.merge!(:master_id=>master.master_id) unless master.nil? || master.master_id.nil?
    opts.merge!(:event_id=>master.parent.composite_id) unless master.nil? || master.parent.nil? || master.parent.composite_id.nil?
    opts.merge!(:master_pid=>master.pid) unless master.nil? || master.pid.nil?
    opts.merge!(:comments=>state_transition_comments) unless state_transition_comments.nil?
    opts.merge!(:from_address=>from_address) unless from_address.nil?
    to_users = get_to_users
    to_users = to_users | get_group_users(event.owner.first) unless event.owner.empty?
    to_users << from_address unless from_address.nil?
    ApplicationMailer.deliver_master_archived_notice(to_users.uniq.join(","),opts)
    true
  end

  state_machine :state, :initial => :created do
    before_transition :to => :created,  :do => :master_created_callback
    before_transition :to => :edited, :do => :master_ready_for_derivative_video_editors_callback
    before_transition :to => :updated, :do => :master_notify_video_editors_of_updates_callback
    before_transition :to => :is_updated, :do => :master_notify_video_editors_of_updates_callback
    before_transition :to => :archive_review, :do => :master_notify_archive_review_callback
    before_transition :to => :archived, :do => :master_notify_archived_callback

    event :master_ready_for_derivative_video_editors do
      transition :created => :edited
    end

    event :master_updated do
      transition :edited => :updated
    end

    event :master_changed do
      transition :updated => :is_updated
    end

    event :master_is_updated do
      transition :is_updated => :updated
    end
    
    event :ready_for_archives do
      transition any => :archive_review
    end

    event :master_archived do
      transition :archive_review => :archived
    end

    state :created do
      def abilities_affected_by_state_change
        [:create_derivative]
      end
    end

    state :edited do
      def abilities_affected_by_state_change
        [:create_derivative,:edit_derivative]
      end
    end

    state :updated do
      def abilities_affected_by_state_change
        [:create_derivative,:edit_derivative]
      end
    end

    state :is_updated do
      def abilities_affected_by_state_change
        [:create_derivative,:edit_derivative]
      end
    end

    state :archive_review do
      def abilities_affected_by_state_change
        [:edit_archive_master]
      end
    end

    state :archived do
      def abilities_affected_by_state_change
        [:edit_archive_master]
      end
    end
  end
end
