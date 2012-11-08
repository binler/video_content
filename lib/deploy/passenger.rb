# Base Capistrano recipe for deploying applications running under passenger

Capistrano::Configuration.instance(:must_exist).load do

  #############################################################
  #  Settings
  #############################################################

  default_run_options[:pty] = true
  set :use_sudo, false
  ssh_options[:paranoid] = false

  #############################################################
  #  SCM
  #############################################################

  set :scm, :git
  set :deploy_via, :remote_cache

  def prompt_with_default(var, default, message = nil)
    set(var) do
      Capistrano::CLI.ui.ask "#{"\n" + message if message}#{var} [#{default}] : "
    end
    set var, default if eval("#{var.to_s}.empty?")
  end

  def current_git_branch
    result = `git branch | grep '^\*'`.gsub(/^\*\ */, '').strip.chomp rescue 'master'
    result.to_s.empty? ? 'master' : result
  end

  namespace :deploy do
    desc "Set SCM branch"
    task :set_scm_branch do
      if rails_env == 'production'
        prompt_with_default(:branch, 'master')
      else
        prompt_with_default(:branch, current_git_branch)
      end
    end
  end

  #############################################################
  #  Passenger
  #############################################################

  desc "Restart Application"
  task :restart_passenger do
    run "touch #{current_path}/tmp/restart.txt"
  end

  #############################################################
  #  Deploy
  #############################################################

  namespace :deploy do
    desc "Execute various commands on the remote environment"
    task :debug, :roles => :app do
      run "/usr/bin/env", :pty => false, :shell => '/bin/bash'
      run "whoami"
      run "pwd"
      run "echo $PATH"
      run "which ruby"
      run "ruby --version"
    end

    desc "Start application in Passenger"
    task :start, :roles => :app do
      restart_passenger
    end

    desc "Restart application in Passenger"
    task :restart, :roles => :app do
      restart_passenger
    end

    task :stop, :roles => :app do
      # Do nothing.
    end

    desc "Run the migrate rake task."
    task :migrate, :roles => :app do
      run "cd #{release_path}; #{bundler} exec #{rake} RAILS_ENV=#{rails_env} db:migrate"
    end

    desc "Symlink shared configs and folders on each release."
    task :symlink_shared do
      symlink_targets.each do | target |
        source, destination = target, target

        if target.respond_to?(:keys)
          source      = target.keys.first
          destination = target.values.first
        end

        run "ln -nfs #{File.join( shared_path, source)} #{File.join( release_path, destination)}"
      end
    end

    desc "Spool up Passenger spawner to keep user experience speedy"
    task :kickstart do
      run "curl -I http://#{domain}"
    end
  end

  namespace :bundle do
    desc "Install gems in Gemfile"
    task :install, :roles => :app do
      run "#{bundler} install --gemfile='#{release_path}/Gemfile'"
    end
  end

  before 'deploy:update_code', 'deploy:set_scm_branch'
  after 'deploy:update_code', 'deploy:symlink_shared', 'bundle:install', 'deploy:migrate'

  after 'deploy', 'deploy:cleanup'
  after 'deploy', 'deploy:restart'
  after 'deploy', 'deploy:kickstart'

end
