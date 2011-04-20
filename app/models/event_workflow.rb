# EventWorkflow is an ActiveRecord couterpart to the Event model. There is a 1:1 relationship.
class EventWorkflow < ActiveRecord::Base
  has_many :permissions, :as => :permissible
  has_many :groups, :through => :permissions

  validates_presence_of :pid

  def self.find_or_create_by_pid(pid)
    existing_workflow = EventWorkflow.find_by_pid(pid)
    existing_workflow ? existing_workflow : EventWorkflow.create(:pid => pid)
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

  def event
    @event ||= Event.load_instance(pid)
  end

  # Having a state machine manage the workflow allows the object to report on its progress
  state_machine :state, :initial => :planned do
    event :film_event do
      transition :planned => :captured
    end

    event :edit_master_video do
      transition :captured => :edited
    end

    event :create_derivatives do
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
