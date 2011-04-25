class Group < ActiveRecord::Base
  has_many :assignments, :dependent => :destroy
  has_many :users, :through => :assignments, :uniq => true
  has_many :permissions, :dependent => :destroy
  has_many :actions, :through => :permissions, :uniq => true

  validates_presence_of   :name
  validates_uniqueness_of :name

  before_save :update_user_collection

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

  def self.hydra_group_names
    hydra_groups.map {|group| group.name}
  end

  def pretty_name
    name ? name.titleize : ''
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

  private

  def update_user_collection
    user_ids = []
    @user_login_array ||= []
    @user_login_array.each do |login|
      user_ids << User.find_or_create_user_by_login(login).id unless login.blank?
    end
    self.user_ids = user_ids
  end

end
