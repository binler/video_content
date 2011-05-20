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
  task :refresh_class_actions => :environment do
    EventWorkflow.create_class_level_actions
  end
end
