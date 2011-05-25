# DerivativeWorkflow is an ActiveRecord counterpart to the Derivative model. There is a 1:1 relationship.
class DerivativeWorkflow < Workflow

  attr_accessor :state_transition_comments, :from_address

  def self.find_or_create_by_pid(pid)
    existing_workflow = DerivativeWorkflow.find_by_pid(pid)
    existing_workflow ? existing_workflow : DerivativeWorkflow.create(:pid => pid)
  end

  # All programmatically significant actions on a Derivative that should be registered with CanCan.
  def self.permissible_actions
    self.workflow_actions + self.state_event_names
  end

  # CRUD actions that can be performed on a Derivative -- used with CanCan.
  def self.workflow_actions
    [ :create_derivative, :edit_derivative, :edit_archive_derivative, :destroy_derivative ]
  end

  # All actions enforced by Hydra::RightsMetadata via Rolemapper
  # Types derived from Hydra::AccessControlsEnforcement
  def self.hydra_roles
    self.show_actions + self.edit_actions
  end

  # Read actions enforced by Hydra::RightsMetadata via RoleMapper.
  def self.show_actions
    [ :discover_derivative, :read_derivative ]
  end

  # Edit actions enforced by Hydra::RightsMetadata via RoleMapper.
  def self.edit_actions
    [ :edit_derivative ]
  end

  def derivative
    @derivative ||= lambda {
      Fedora::Repository.register(ActiveFedora.fedora_config[:url], '')
      require_solr
      Derivative.load_instance(pid)
    }.call
  end
  alias_method :parent, :derivative

  def derivative_ready_for_derivative_video_editors_callback
    opts = {}
    opts.merge!(:derivative_id=>derivative.derivative_id) unless derivative.nil? || derivative.derivative_id.nil? || derivative.derivative_id.empty?
    opts.merge!(:parent_id=>derivative.parent.composite_id) unless derivative.nil? || derivative.parent.nil? || derivative.parent.composite_id.nil?
    opts.merge!(:derivative_pid=>derivative.pid) unless derivative.nil? || derivative.pid.nil?
    opts.merge!(:comments=>state_transition_comments) unless state_transition_comments.nil?
    opts.merge!(:from_address=>from_address) unless from_address.nil?
    to_opts = {}
    to_opts.merge!({:group=>derivative.owner}) unless derivative.owner.nil?
    #add creator to email
    to_users = get_to_users(to_opts)
    to_users << from_address unless from_address.nil?
    ApplicationMailer.deliver_derivative_video_captured_notice(to_users.uniq.join(","),opts)
    true
  end

  def derivative_notify_video_editors_of_updates_callback
    opts = {}
    opts.merge!(:derivative_id=>derivative.derivative_id) unless derivative.nil? || derivative.derivative_id.nil? || derivative.derivative_id.empty?
    opts.merge!(:parent_id=>derivative.parent.composite_id) unless derivative.nil? || derivative.parent.nil? || derivative.parent.composite_id.nil?
    opts.merge!(:derivative_pid=>derivative.pid) unless derivative.nil? || derivative.pid.nil?
    opts.merge!(:comments=>state_transition_comments) unless state_transition_comments.nil?
    opts.merge!(:from_address=>from_address) unless from_address.nil?
    to_opts = {}
    to_opts.merge!({:group=>derivative.owner}) unless derivative.owner.nil?
    #add creator to email
    to_users = get_to_users(to_opts)
    to_users << from_address unless from_address.nil?
    ApplicationMailer.deliver_derivative_video_updated_notice(to_users.uniq.join(","),opts)
    true
  end

  def derivative_notify_archive_review_callback
    opts = {}
    opts.merge!(:derivative_id=>derivative.derivative_id) unless derivative.nil? || derivative.derivative_id.nil? || derivative.derivative_id.empty?
    opts.merge!(:parent_id=>derivative.parent.composite_id) unless derivative.nil? || derivative.parent.nil? || derivative.parent.composite_id.nil?
    opts.merge!(:derivative_pid=>derivative.pid) unless derivative.nil? || derivative.pid.nil?
    opts.merge!(:comments=>state_transition_comments) unless state_transition_comments.nil?
    opts.merge!(:from_address=>from_address) unless from_address.nil?
    to_opts = {}
    to_opts.merge!({:group=>derivative.owner}) unless derivative.owner.nil?
    #add creator to email
    to_users = get_to_users(to_opts)
    to_users << from_address unless from_address.nil?
    ApplicationMailer.deliver_derivative_archive_review_notice(to_users.uniq.join(","),opts)
    true
  end

  def derivative_notify_archived_callback
    opts = {}
    opts.merge!(:derivative_id=>derivative.derivative_id) unless derivative.nil? || derivative.derivative_id.nil? || derivative.derivative_id.empty?
    opts.merge!(:parent_id=>derivative.parent.composite_id) unless derivative.nil? || derivative.parent.nil? || derivative.parent.composite_id.nil?
    opts.merge!(:derivative_pid=>derivative.pid) unless derivative.nil? || derivative.pid.nil?
    opts.merge!(:comments=>state_transition_comments) unless state_transition_comments.nil?
    opts.merge!(:from_address=>from_address) unless from_address.nil?
    to_opts = {}
    to_opts.merge!({:group=>derivative.owner}) unless derivative.owner.nil?
    #add creator to email
    to_users = get_to_users(to_opts)
    to_users << from_address unless from_address.nil?
    ApplicationMailer.deliver_derivative_archived_notice(to_users.uniq.join(","),opts)
    true
  end

  state_machine :state, :initial => :created do
    before_transition :to => :edited,         :do => :derivative_ready_for_derivative_video_editors_callback
    before_transition :to => :updated,        :do => :derivative_notify_video_editors_of_updates_callback
    before_transition :to => :is_updated,     :do => :derivative_notify_video_editors_of_updates_callback
    before_transition :to => :archive_review, :do => :derivative_notify_archive_review_callback
    before_transition :to => :archived,       :do => :derivative_notify_archived_callback

    event :notify_derivative_ready_for_new_derivatives do
      transition :created => :edited
    end

    event :notify_derivative_updated do
      transition :edited => :updated
    end

    event :notify_derivative_changed do
      transition :updated => :is_updated
    end

    event :notify_derivative_is_updated do
      transition :is_updated => :updated
    end
    
    event :send_to_archives do
      transition :created    => :archive_review
      transition :edited     => :archive_review
      transition :updated    => :archive_review
      transition :is_updated => :archive_review
    end

    event :archive_derivative do
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
        [:edit_archive_derivative]
      end

      def restrict_editing_to_archival_groups?
        true
      end
    end

    state :archived do
      def abilities_affected_by_state_change
        [:edit_archive_derivative]
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
