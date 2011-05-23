# EventWorkflow is an ActiveRecord counterpart to the Event model. There is a 1:1 relationship.
class EventWorkflow < Workflow

  attr_accessor :state_transition_comments, :from_address

  def self.find_or_create_by_pid(pid)
    existing_workflow = EventWorkflow.find_by_pid(pid)
    existing_workflow ? existing_workflow : EventWorkflow.create(:pid => pid)
  end

  # All programmatically significant actions on an Event that should be registered with CanCan.
  def self.permissible_actions
    self.workflow_actions + self.state_event_names
  end

  # CRUD actions that can be performed on an Event -- used with CanCan.
  def self.workflow_actions
    [ :create_event, :edit_event, :edit_archive_event, :destroy_event ]
  end

  # All actions enforced by Hydra::RightsMetadata via Rolemapper
  # Types derived from Hydra::AccessControlsEnforcement
  def self.hydra_roles
    self.show_actions + self.edit_actions
  end

  # Edit actions enforced by Hydra::RightsMetadata via RoleMapper.
  def self.edit_actions
    [ :edit_event ]
  end

  # Read actions enforced by Hydra::RightsMetadata via RoleMapper.
  def self.show_actions
    [ :discover_event, :read_event ]
  end

  def event
    @event ||= lambda {
      Fedora::Repository.register(ActiveFedora.fedora_config[:url], '')
      require_solr
      Event.load_instance(pid)
    }.call
  end
  alias_method :parent, :event

  def event_created_callback
    ApplicationMailer.deliver_event_created_notice(SMTP_DEBUG_EMAIL_ADDRESS) if Rails.env =~ /^dev/
  end

  def event_ready_for_video_editors_callback
    opts = {}
    opts.merge!(:event_id=>event.composite_id) unless event.nil? || event.composite_id.nil?
    opts.merge!(:event_pid=>event.pid) unless event.nil? || event.pid.nil?
    opts.merge!(:comments=>state_transition_comments) unless state_transition_comments.nil?
    opts.merge!(:from_address=>from_address) unless from_address.nil?
    to_opts = {}
    to_opts.merge!({:group=>event.owner}) unless event.owner.nil?
    #add creator to email
    to_users = get_to_users(to_opts)
    to_users << from_address unless from_address.nil?
    ApplicationMailer.deliver_event_updated_notice(to_users.uniq.join(","),opts)
    true
  end

  def event_notify_video_editors_of_updates_callback
    opts = {}
    opts.merge!(:event_id=>event.composite_id) unless event.nil? || event.composite_id.nil?
    opts.merge!(:event_pid=>event.pid) unless event.nil? || event.pid.nil?
    opts.merge!(:comments=>state_transition_comments) unless state_transition_comments.nil?
    opts.merge!(:from_address=>from_address) unless from_address.nil?
    to_opts = {}
    to_opts.merge!({:group=>event.owner}) unless event.owner.nil?
    #add creator to email
    to_users = get_to_users(to_opts)
    to_users << from_address unless from_address.nil?
    ApplicationMailer.deliver_event_updated_notice(to_users.uniq.join(","),opts)
    true
  end

  def event_notify_archive_review_callback
    opts = {}
    opts.merge!(:event_id=>event.composite_id) unless event.nil? || event.composite_id.nil?
    opts.merge!(:event_pid=>event.pid) unless event.nil? || event.pid.nil?
    opts.merge!(:comments=>state_transition_comments) unless state_transition_comments.nil?
    opts.merge!(:from_address=>from_address) unless from_address.nil?
    to_opts = {}
    to_opts.merge!({:group=>event.owner}) unless event.owner.nil?
    #add creator to email
    to_users = get_to_users(to_opts)
    to_users << from_address unless from_address.nil?
    ApplicationMailer.deliver_event_archive_review_notice(to_users.uniq.join(","),opts)
    true
  end

  def event_notify_archived_callback
    opts = {}
    opts.merge!(:event_id=>event.composite_id) unless event.nil? || event.composite_id.nil?
    opts.merge!(:event_pid=>event.pid) unless event.nil? || event.pid.nil?
    opts.merge!(:comments=>state_transition_comments) unless state_transition_comments.nil?
    opts.merge!(:from_address=>from_address) unless from_address.nil?
    to_opts = {}
    to_opts.merge!({:group=>event.owner}) unless event.owner.nil?
    #add creator to email
    to_users = get_to_users(to_opts)
    to_users << from_address unless from_address.nil?
    ApplicationMailer.deliver_event_archived_notice(to_users.uniq.join(","),opts)
    true
  end

  state_machine :state, :initial => :planned do
    before_transition :to => :planned,  :do => :event_created_callback
    before_transition :to => :captured, :do => :event_ready_for_video_editors_callback
    before_transition :to => :updated, :do => :event_notify_video_editors_of_updates_callback
    before_transition :to => :is_updated, :do => :event_notify_video_editors_of_updates_callback
    before_transition :to => :archive_review, :do => :event_notify_archive_review_callback
    before_transition :to => :archived, :do => :event_notify_archived_callback

    event :event_ready_for_video_editors do
      transition :planned => :captured
    end

    event :event_updated do
      transition :captured => :updated
    end

    event :event_changed do
      transition :updated => :is_updated
    end

    event :event_is_updated do
      transition :is_updated => :updated
    end

    event :ready_for_archives do
      transition :planned => :archive_review
      transition :captured => :archive_review
      transition :updated => :archive_review
      transition :is_updated => :archive_review
    end

    event :event_archived do
      transition :archive_review => :archived
    end

    state :planned do
      def abilities_affected_by_state_change
        [:create_master]
      end
    end

    state :captured do
      def abilities_affected_by_state_change
        [:create_master,:edit_master]
      end
    end

    state :updated do
      def abilities_affected_by_state_change
        [:create_master,:create_derivative,:edit_derivative,:edit_master]
      end
    end

    state :is_updated do
      def abilities_affected_by_state_change
        [:create_master,:create_derivative,:edit_derivative,:edit_master]
      end
    end

    state :archive_review do
      def abilities_affected_by_state_change
        [:edit_archive_event,:edit_event]
      end
    end

    state :archived do
      def abilities_affected_by_state_change
        [:edit_archive_event,:edit_event]
      end
    end
  end
end
