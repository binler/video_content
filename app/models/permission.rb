class Permission < ActiveRecord::Base
  belongs_to :permissible, :polymorphic => true
  belongs_to :group
end
