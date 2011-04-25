class Permission < ActiveRecord::Base
  belongs_to :action
  belongs_to :group

  validates_presence_of :action_id
  validates_presence_of :group_id

  validates_uniqueness_of :action_id, :scope => :group_id
end
