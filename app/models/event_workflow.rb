require 'mediashelf/active_fedora_helper'

# EventWorkflow is an ActiveRecord counterpart to the Event model. There is a 1:1 relationship.
class EventWorkflow < ActiveRecord::Base
  
  include MediaShelf::ActiveFedoraHelper

  has_many :actions, :as => :permissible
  has_many :permissions, :through => :actions

  validates_presence_of :pid
  after_create :publish_permissible_actions

  attr_accessor :state_transition_comments

  def self.find_or_create_by_pid(pid)
    existing_workflow = EventWorkflow.find_by_pid(pid)
    existing_workflow ? existing_workflow : EventWorkflow.create(:pid => pid)
  end

  # All programmatically significant actions; actions that should be registered with CanCan.
  def self.permissible_actions
    @@permissible_actions ||= self.workflow_actions + self.state_event_names
  end

  def self.permissible_action_names
    permissible_actions.map {|a| a.to_s }
  end

  # All actions enforced by Hydra::RightsMetadata via Rolemapper
  # Types derived from Hydra::AccessControlsEnforcement
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

  # CRUD actions that can be performed on an Event and its related Classes -- used with CanCan.
  def self.workflow_actions
    [
      :create_event, :edit_event, :edit_archive_event, :destroy_event,
      :create_master, :edit_master, :edit_archive_master, :destroy_master,
      :create_derivative, :edit_derivative, :edit_archive_derivative, :destroy_derivative
    ]
  end

  # Edit actions enforced by Hydra::RightsMetadata via RoleMapper.
  def self.edit_actions
    [ :edit_event, :edit_master, :edit_derivative ]
  end

  # Read actions enforced by Hydra::RightsMetadata via RoleMapper.
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
    Fedora::Repository.register(ActiveFedora.fedora_config[:url],  "")
    require_solr
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

  def event_ready_for_video_editors_callback
    opts = {}
    opts.merge!(:event_id=>event.composite_id) unless event.nil? || event.composite_id.nil?
    opts.merge!(:event_pid=>event.pid) unless event.nil? || event.pid.nil?
    opts.merge!(:comments=>@state_transition_comments) unless @state_transition_comments.nil?
    ApplicationMailer.deliver_event_planned_notice(SMTP_DEBUG_EMAIL_ADDRESS,opts)
    # TODO: send to users associated with: abilities_affected_by_state_change 
    true
  end

  def event_notify_video_editors_of_updates_callback
    opts = {}
    opts.merge!(:event_id=>event.composite_id) unless event.nil? || event.composite_id.nil?
    opts.merge!(:event_pid=>event.pid) unless event.nil? || event.pid.nil?
    opts.merge!(:comments=>@state_transition_comments) unless @state_transition_comments.nil?
    ApplicationMailer.deliver_event_updated_notice(SMTP_DEBUG_EMAIL_ADDRESS,opts)
    # TODO: send to users associated with: abilities_affected_by_state_change 
    true
  end

  # Having a state machine manage the workflow allows the object to report on its progress
  state_machine :state, :initial => :planned do
    before_transition :to => :planned,  :do => :event_created_callback
    before_transition :to => :captured, :do => :event_ready_for_video_editors_callback
    before_transition :to => :updated, :do => :event_notify_video_editors_of_updates_callback
    before_transition :to => :is_updated, :do => :event_notify_video_editors_of_updates_callback

    event :ready_for_video_editors do
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

    #event :edit_master_video do
    #  transition :captured => :edited
    #end

    #event :publish_derivatives do
    #  transition :edited => :processed
    #end

    event :approve_for_archival do
      transition :processed => :archived
    end

    state :planned do
      def abilities_affected_by_state_change
        [:create_master]
      end
    end

    state :film_event do
    end

    state :captured do
      def abilities_affected_by_state_change
        [:create_derivative]
      end
    end

    state :updated do
      def abilities_affected_by_state_change
        []
      end
    end

    state :is_updated do
    end

    state :processed do
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
