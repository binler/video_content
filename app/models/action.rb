class Action < ActiveRecord::Base
  belongs_to :permissible, :polymorphic => true
  has_many :permissions, :dependent => :destroy

  validates_presence_of :name
  validates_presence_of :permissible_type

  validates_uniqueness_of :name, :scope => [:permissible_type, :permissible_id]

  named_scope :permissible_actions_for, lambda {|*args|
    user, subject_class, subject = args.flatten

    if subject
      matching_criteria = ["`users`.`id` = ? AND `actions`.`permissible_type` = ? AND `actions`.`permissible_id` = ?", user.id, subject_class.class_name, subject.id ]
    else
      matching_criteria = ["`users`.`id` = ? AND `actions`.`permissible_type` = ? AND `actions`.`permissible_id` IS NULL", user.id, subject_class.class_name ]
    end
    
    {
      :select     => '`actions`.`name`',
      :joins      => 'INNER JOIN `permissions` ON `permissions`.`action_id` = `actions`.`id`
                      INNER JOIN `groups` ON `permissions`.`group_id` = `groups`.`id`
                      INNER JOIN `assignments` ON `groups`.`id` = `assignments`.`group_id`
                      INNER JOIN `users` ON `assignments`.`user_id` = `users`.`id`',
      :conditions => matching_criteria
    }
  }

  named_scope :permissible_class_actions_for_login, lambda {|*args|
    login = args.flatten
    {
      :select     => '`actions`.`name`, `actions`.`permissible_type`',
      :joins      => 'INNER JOIN `permissions` ON `permissions`.`action_id` = `actions`.`id`
                      INNER JOIN `groups` ON `permissions`.`group_id` = `groups`.`id`
                      INNER JOIN `assignments` ON `groups`.`id` = `assignments`.`group_id`
                      INNER JOIN `users` ON `assignments`.`user_id` = `users`.`id`',
      :conditions => ["`users`.`login` = ? AND `actions`.`permissible_id` IS NULL", login ]
    }
  }

  named_scope :permissible_instance_actions_for_login, lambda {|*args|
    login = args.flatten
    {
      :select     => '`actions`.`name`, `actions`.`permissible_type`, `actions`.`permissible_id`',
      :joins      => 'INNER JOIN `permissions` ON `permissions`.`action_id` = `actions`.`id`
                      INNER JOIN `groups` ON `permissions`.`group_id` = `groups`.`id`
                      INNER JOIN `assignments` ON `groups`.`id` = `assignments`.`group_id`
                      INNER JOIN `users` ON `assignments`.`user_id` = `users`.`id`',
      :conditions => ["`users`.`login` = ? AND `actions`.`permissible_id` IS NOT NULL", login ]
    }
  }


  named_scope :find_by_class_and_action_name, lambda {|class_name, action_name|
    {
      :conditions => ["`actions`.`permissible_type` = ? AND `actions`.`name` = ? AND `actions`.`permissible_id` IS NULL", class_name, action_name]
    }
  }

  named_scope :available_actions, {
    :select     => '`actions`.`name`',
    :conditions => ['`actions`.`permissible_id` IS NULL']
  }

  def self.available_action_names
    available_actions.map{|action| action.name}
  end

end
