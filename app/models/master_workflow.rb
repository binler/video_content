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

  def master_ready_for_derivative_video_editors_callback
    opts = {}
    opts.merge!(:master_id=>master.master_id) unless master.nil? || master.master_id.nil? || master.master_id.empty?
    opts.merge!(:event_id=>master.parent.composite_id) unless master.nil? || master.parent.nil? || master.parent.composite_id.nil?
    opts.merge!(:master_pid=>master.pid) unless master.nil? || master.pid.nil?
    opts.merge!(:comments=>state_transition_comments) unless state_transition_comments.nil?
    opts.merge!(:from_address=>from_address) unless from_address.nil?
    to_opts = {}
    to_opts.merge!({:group=>master.owner}) unless master.owner.nil?
    #add creator to email
    to_users = get_to_users(to_opts)
    to_users << from_address unless from_address.nil?
    ApplicationMailer.deliver_master_video_captured_notice(to_users.uniq.join(","),opts)
    true
  end

  def master_notify_video_editors_of_updates_callback
    opts = {}
    opts.merge!(:master_id=>master.master_id) unless master.nil? || master.master_id.nil? || master.master_id.empty?
    opts.merge!(:event_id=>master.parent.composite_id) unless master.nil? || master.parent.nil? || master.parent.composite_id.nil?
    opts.merge!(:master_pid=>master.pid) unless master.nil? || master.pid.nil?
    opts.merge!(:comments=>state_transition_comments) unless state_transition_comments.nil?
    opts.merge!(:from_address=>from_address) unless from_address.nil?
    to_opts = {}
    to_opts.merge!({:group=>master.owner}) unless master.owner.nil?
    #add creator to email
    to_users = get_to_users(to_opts)
    to_users << from_address unless from_address.nil?
    ApplicationMailer.deliver_master_video_updated_notice(to_users.uniq.join(","),opts)
    true
  end

  def master_notify_archive_review_callback
    opts = {}
    opts.merge!(:master_id=>master.master_id) unless master.nil? || master.master_id.nil? || master.master_id.empty?
    opts.merge!(:event_id=>master.parent.composite_id) unless master.nil? || master.parent.nil? || master.parent.composite_id.nil?
    opts.merge!(:master_pid=>master.pid) unless master.nil? || master.pid.nil?
    opts.merge!(:comments=>state_transition_comments) unless state_transition_comments.nil?
    opts.merge!(:from_address=>from_address) unless from_address.nil?
    to_opts = {}
    to_opts.merge!({:group=>master.owner}) unless master.owner.nil?
    #add creator to email
    to_users = get_to_users(to_opts)
    to_users << from_address unless from_address.nil?
    ApplicationMailer.deliver_master_archive_review_notice(to_users.uniq.join(","),opts)
    true
  end

  def master_notify_archived_callback
    opts = {}
    opts.merge!(:master_id=>master.master_id) unless master.nil? || master.master_id.nil? || master.master_id.empty?
    opts.merge!(:event_id=>master.parent.composite_id) unless master.nil? || master.parent.nil? || master.parent.composite_id.nil?
    opts.merge!(:master_pid=>master.pid) unless master.nil? || master.pid.nil?
    opts.merge!(:comments=>state_transition_comments) unless state_transition_comments.nil?
    opts.merge!(:from_address=>from_address) unless from_address.nil?
    to_opts = {}
    to_opts.merge!({:group=>master.owner}) unless master.owner.nil?
    #add creator to email
    to_users = get_to_users(to_opts)
    to_users << from_address unless from_address.nil?
    ApplicationMailer.deliver_master_archived_notice(to_users.uniq.join(","),opts)
    true
  end

  state_machine :state, :initial => :created do
    before_transition :to => :edited, :do => :master_ready_for_derivative_video_editors_callback
    before_transition :to => :updated, :do => :master_notify_video_editors_of_updates_callback
    before_transition :to => :is_updated, :do => :master_notify_video_editors_of_updates_callback
    before_transition :to => :archive_review, :do => :master_notify_archive_review_callback
    before_transition :to => :archived, :do => :master_notify_archived_callback

    event :notify_master_ready_for_derivatives do
      transition :created => :edited
    end

    event :notify_master_updated do
      transition :edited => :updated
    end

    event :notify_master_changed do
      transition :updated => :is_updated
    end

    event :master_is_updated do
      transition :is_updated => :updated
    end
    
    event :send_to_archives do
      transition :created => :archive_review
      transition :edited => :archive_review
      transition :updated => :archive_review
      transition :is_updated => :archive_review
    end

    event :archive_master do
      transition :archive_review => :archived
    end

    state :created do
      def abilities_affected_by_state_change
        [:create_derivative]
      end
    end

    state :edited do
      def abilities_affected_by_state_change
        [:create_derivative, :edit_derivative]
      end
    end

    state :updated do
      def abilities_affected_by_state_change
        [:create_derivative, :edit_derivative]
      end
    end

    state :is_updated do
      def abilities_affected_by_state_change
        [:create_derivative, :edit_derivative]
      end
    end

    state :archive_review do
      def abilities_affected_by_state_change
        [:edit_archive_master]
      end

      def restrict_editing_to_archival_groups?
        true
      end
    end

    state :archived do
      def abilities_affected_by_state_change
        [:edit_archive_master]
      end

      def restrict_editing_to_archival_groups?
        true
      end

      def restrict_editing_to_archival_fields?
        true
      end
    end
  end
end
