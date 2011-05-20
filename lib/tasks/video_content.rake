namespace :groups do
  desc "Refresh groups and group members from config file."
  task :refresh => :environment do
    group_config = YAML::load(File.open("#{RAILS_ROOT}/config/groups.yml"))
    group_config.each_pair do |group_name, members|
      puts "Group: #{group_name}"
      group = Group.find_or_create_hydra_group_by_name(group_name)

      if members && members.any?
        members.each do |member_uid|
          puts " - #{member_uid}"
          member = User.find_or_create_user_by_login(member_uid)
          member.groups << group rescue false
        end
      end

    end
  end
end

namespace :actions do
  desc "Add defined class level workflow actions that do not exist and remove stale ones."
  task :refresh_class_actions => :environment do
    actions_to_remove = Action.find(:all, :conditions => ['`actions`.`permissible_id` IS NULL'])
    Workflow.control_classes.each do |klass|
      actions_to_remove = actions_to_remove - klass.create_class_level_actions
    end
    actions_to_remove.collect{ |action| action.destroy }
  end
end
