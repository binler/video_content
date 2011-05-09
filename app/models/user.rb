require 'net/ldap'
require 'vendor/plugins/blacklight/app/models/user.rb'

class User < ActiveRecord::Base
  include Blacklight::User::Authlogic
  has_many :assignments, :dependent => :destroy
  has_many :groups, :through => :assignments, :uniq => true

  validates_uniqueness_of :login

  before_validation_on_create :enrich_data_from_ldap
  before_validation_on_update :purge_remaining_groups
  after_validation_on_create  :validate_netid

  named_scope :users_in_hydra_group, lambda {|*group|
    {
      :select     => 'login',
      :joins      => 'INNER JOIN `assignments` ON `assignments`.`user_id` = `users`.`id`
                      INNER JOIN `groups` ON `groups`.`id` = `assignments`.`group_id`',
      :conditions => ["`group`.`is_hydra_role` = ? AND `assignments`.`group_id` = ?", true, group.flatten.first.id]
    } unless group.flatten.first.blank?
  }

  named_scope :logins_permitted_to_perform_action, lambda {|*args|
    action_name = args.flatten
    {
      :select     => '`users`.`login`',
      :joins      => 'INNER JOIN `assignments` ON `users`.`id` = `assignments`.`user_id`
                      INNER JOIN `groups` ON `assignments`.`group_id` = `groups`.`id`
                      INNER JOIN `permissions` ON `groups`.`id` = `permissions`.`group_id`
                      INNER JOIN `actions` ON `permissions`.`action_id` = `actions`.`id`',
      :conditions => ["`actions`.`name` = ? AND `actions`.`permissible_id` IS NULL", action_name ]
    }
  }

  attr_accessor :invalid_netid, :no_groups_selected

  def self.ldap_lookup(netid)
    return nil if netid.blank?
    ldap = Net::LDAP.new :host => LDAP_HOST,
                         :port => LDAP_PORT,
                         :auth => { :method   => LDAP_ACCESS_METHOD,
                                    :username => LDAP_ACCESS_USER,
                                    :password => LDAP_ACCESS_PASSWORD
                                  }
    results = ldap.search(
      :base          => LDAP_BASE,
      :attributes    => [
                          LDAP_USER_ID,
                          LDAP_FIRST_NAME,
                          LDAP_LAST_NAME,
                          LDAP_PREFERRED_NAME,
                          LDAP_DEPARTMENT,
                        ],
      :filter        => Net::LDAP::Filter.eq( LDAP_USER_ID, netid ),
      :return_result => true
    )
    results.first
  end

  def self.type_from_affiliation(affiliation)
    case
    when affiliation == 'Faculty'
      'Faculty'
    when affiliation == 'Staff'
      'Staff'
    else
      'Student'
    end
  end

  def self.create_from_ldap(netid)
    person       = self.ldap_lookup(netid)
    account_type = self.type_from_affiliation(person[LDAP_DEPARTMENT].first)
    User.create(
      :login        => person[LDAP_USER_ID.to_sym].first,
      :email        => "#{person[LDAP_USER_ID.to_sym].first}@nd.edu",
      :first_name   => person[LDAP_FIRST_NAME.to_sym].first,
      :last_name    => person[LDAP_LAST_NAME.to_sym].first,
      :nickname     => person[LDAP_PREFERRED_NAME.to_sym].first,
      :account_type => account_type
    )
  end

  def self.find_or_create_user_by_login(login)
    existing_user = User.find_by_login(login)
    existing_user ? existing_user : User.create_from_ldap(login)
  end

  def self.user_names_in_hydra_group(group)
    user_names_in_hydra_group(group).map{|user| user.login}
  end

  # Assume that all users are from ND
  def nd?
    true
  end
  alias_method :nd, :nd?

  def in_group?(group_name)
    groups.include? Group.find_by_name(group_name.to_s)
  end

  def add_to_group(group)
    groups << group if group 
  end

  def add_to_group_by_name(group_name)
    group = Group.find_by_name(group_name)
    add_to_group group
  end
  
  def permissible_actions_on(subject_class, subject = nil)
    Action.permissible_actions_for(self, subject_class, subject).map{|a| a.name.to_sym }
  end

  def name
    if nickname && nickname.split(' ').count > 1
      nickname
    else
      # NOTE that origionally the first_name and last_name attributes were defined in USER_ATTRIBUTES found:
      # vendor/plugins/hydra_repository/lib/hydra/generic_user_attributes.rb
      # They have been removed as a quick workaround
      "#{self.first_name} #{self.last_name}"
    end
  end

  def name_with_login
    "#{name} (#{login})"
  end

  def require_password?
    (self.nd == false) && (self.updated_account == false)
  end

  def hydra_groups
    Group.hydra_groups_for_user(self)
  end

  def hydra_group_names
    hydra_groups.map{|group| group.name} rescue nil
  end

  private

  def enrich_data_from_ldap
    attrs = User.ldap_lookup(login)
    if attrs.nil? || attrs[LDAP_USER_ID.to_sym].first.blank?
      self.invalid_netid = true
    else
      self.login        ||= attrs[LDAP_USER_ID.to_sym].first
      self.email        ||= "#{attrs[LDAP_USER_ID.to_sym].first}@nd.edu"
      self.first_name   ||= attrs[LDAP_FIRST_NAME.to_sym].first
      self.last_name    ||= attrs[LDAP_LAST_NAME.to_sym].first
      self.nickname     ||= attrs[LDAP_PREFERRED_NAME.to_sym].first
      self.account_type ||= User.type_from_affiliation(attrs[LDAP_USER_ID.to_sym].first)
      self.email        ||= "#{login}@nd.edu"
    end
  end

  def purge_remaining_groups
    group_ids = [] if no_groups_selected
  end

  def validate_netid
    if self.invalid_netid && self.invalid_netid == true
      self.errors.add('login', 'The NetID provided is not present in LDAP')
    end
  end

end
