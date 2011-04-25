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

end
