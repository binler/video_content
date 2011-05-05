class Group < ActiveRecord::Base
  has_many :assignments, :dependent => :destroy
  has_many :users, :through => :assignments, :uniq => true
  has_many :permissions, :dependent => :destroy
  has_many :actions, :through => :permissions, :uniq => true

  validates_presence_of   :name
  validates_uniqueness_of :name

  before_save :update_user_collection, :upate_permissible_actions

  named_scope :restricted,   :conditions => ["restricted = ?", true ]
  named_scope :unrestricted, :conditions => ["restricted = ?", false]

  named_scope :for_cancan,     :conditions => ["for_cancan = ?", true ]
  named_scope :not_for_cancan, :conditions => ["for_cancan = ?", false]

  named_scope :hydra_groups, :select => 'name', :conditions => ["is_hydra_role = ?", true]
  named_scope :hydra_groups_for_user, lambda {|*user|
    {
      :select     => 'name',
      :joins      => 'INNER JOIN `assignments` ON `assignments`.`group_id` = `groups`.`id`',
      :conditions => ["`groups`.`is_hydra_role` = ? AND `assignments`.`user_id` = ?", true, user.flatten.first.id]
    } unless user.flatten.first.blank?
  }

  named_scope :actions_for_class, lambda {|klass, group_id|
    {
      :select     => '`actions`.`name`',
      :joins      => 'INNER JOIN `permissions` ON `groups`.`id` = `permissions`.`group_id`
                      INNER JOIN `actions` ON `permissions`.`action_id` = `actions`.`id`',
      :conditions =>  ["`actions`.`permissible_type` = ? AND `actions`.`permissible_id` IS NULL AND `groups`.`id` = ? ", klass.class_name, group_id ]
    }
  }

  attr_accessor :permissible_actions, :no_permissions_granted, :can_have_permissions_updated

  def self.find_or_create_hydra_group_by_name(name)
    existing_group = Group.find_by_name(name)
    existing_group ? existing_group : Group.create( :name => name, :is_hydra_role => true )
  end

  def self.hydra_group_names
    hydra_groups.map {|group| group.name}
  end

  def pretty_name
    name ? name.humanize.titleize : ''
  end

  def user_logins
    collection = users.map{|u| u.login}
    collection.size > 0 ?  "#{collection.join(', ')}, " : ""
  end

  def user_logins=(value)
    @user_login_array = value.split(',').reject{|i| i.blank?}.map{|i| i.strip}
  end

  # Protect group names from being changed when they are programmatically significant
  def name=(value)
    write_attribute(:name, value) unless self.for_cancan?
  end

  def action_names_for_class(klass)
    Group.actions_for_class(klass, self.id).map{|a| a.name.to_sym }
  end

  def purge_granted_permissions
    actions = []
  end

  private

  def update_user_collection
    user_ids = []
    @user_login_array ||= []
    @user_login_array.each do |login|
      user_ids << User.find_or_create_user_by_login(login).id unless login.blank?
    end
    self.user_ids = user_ids
  end

  # NOTE this method has only implemented permission granting on a class level basis
  def upate_permissible_actions
    if can_have_permissions_updated
      if no_permissions_granted
        purge_granted_permissions
      else
        granted_actions = []
        permissible_actions.each_pair do |class_name, action_names|
          action_names.each do |action|
            target = Action.find_by_class_and_action_name(class_name.camelize, action)
            target ? granted_actions << target.first : false
          end
        end
        self.actions = granted_actions
      end
    end
  end

end
