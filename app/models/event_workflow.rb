# EventWorkflow is an ActiveRecord couterpart to the Event model. There is a 1:1 relationship.
class EventWorkflow < ActiveRecord::Base
  has_many :actions, :as => :permissible
  has_many :permissions, :through => :actions

  validates_presence_of :pid
  after_create :publish_permissible_actions

  def self.find_or_create_by_pid(pid)
    existing_workflow = EventWorkflow.find_by_pid(pid)
    existing_workflow ? existing_workflow : EventWorkflow.create(:pid => pid)
  end

  def self.permissible_actions
    @@permissible_actions ||= self.workflow_actions + self.state_event_names
  end

  def self.permissible_action_names
    permissible_actions.map {|a| a.to_s }
  end

  # Types taken from Hydra::AccessControlsEnforcement
  def self.hydra_roles
    @@hydra_roles ||= self.show_actions + self.edit_actions
  end

  def self.hydra_role_names
    hydra_roles.map {|a| a.to_s }
  end

  def self.state_event_names
    state_machine.events.map {|e| e.name}
  end

  def self.state_names
    state_machine.states.map {|s| s.name}
  end

  def self.state_query_methods
    state_machine.states.map {|s| "#{s.name.to_s}?".to_sym }
  end

  def self.workflow_actions
    [
      :create_event, :edit_event, :destroy_event,
      :create_master, :edit_master, :destroy_master,
      :create_derivative, :edit_derivative, :destroy_derivative
    ]
  end

  def self.edit_actions
    [ :edit_event, :edit_master, :edit_derivative, ]
  end

  def self.show_actions
    [
      :discover_event, :read_event,
      :discover_master, :read_master,
      :discover_derivative, :read_derivative
    ]
  end

  def self.create_class_level_actions
    self.permissible_actions.each do |action_name|
      Action.create(:name => action_name.to_s, :permissible_type => self.class_name)
    end
  end

  def event
    @event ||= Event.load_instance(pid)
  end

  def refresh_permissible_actions
    # Ensure that an Action is available for all permissible_actions
    EventWorkflow.permissible_actions.each do |action|
      Action.create(:name => action.to_s, :permissible_id => self.id, :permissible_type => self.class.class_name)
    end
  end
  alias_method :publish_permissible_actions, :refresh_permissible_actions

  def event_created_callback
    ApplicationMailer.deliver_event_created_notice(SMTP_DEBUG_EMAIL_ADDRESS) if Rails.env =~ /^dev/
  end

  # Having a state machine manage the workflow allows the object to report on its progress
  state_machine :state, :initial => :planned do
    before_transition :to => :planned, :do => :event_created_callback

    event :film_event do
      transition :planned => :captured
    end

    event :edit_master_video do
      transition :captured => :edited
    end

    event :publish_derivatives do
      transition :edited => :processed
    end

    event :approve_for_archival do
      transition :processed => :archived
    end

    state :planned do
    end

    state :captured do
    end

    state :edited do
    end

    state :processed do
    end

    state :archived do
    end
  end
end
