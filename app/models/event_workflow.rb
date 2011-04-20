class EventWorkflow < ActiveRecord::Base
  has_many :permissions, :as => :permissible
  has_many :groups, :through => :permissions

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
