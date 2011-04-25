# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

Group.create([{ :name => 'root', :for_cancan => true, :restricted => true }])

admin = Group.find_by_name('root')

['dbrubak1','rbalekai','rjohns14'].each do |login|
  user = User.find_or_create_user_by_login(login)
  user.groups << admin
end

EventWorkflow.create_class_level_actions
