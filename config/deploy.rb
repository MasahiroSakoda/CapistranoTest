# -*- coding: utf-8 -*-
require 'capistrano_colors'
require 'bundler/capistrano'

set :bundle_flags, "--no-deployment --without test development"

set :application, "CapistranoTest"
set :repository,  "git@github.com:MasahiroSakoda/CapistranoTest.git"
set :scm, :git
set :branch, "master"
set :daploy_via, :remote_cache
set :deploy_to, "/var/www/rails/#{application}"
set :rails_env, "production"

# Your HTTP server, Apache/etc
role :web, "your web-server here"

# This may be the same as your `Web` server
role :app, "your app-server here"

# This is where Rails migrations will run
role :db,  "your primary db-server here", :primary => true

# role :db,  "your slave db-server here"

# SSH settings
set :user, 'user'
set :user_group, 'user_group'
ssh_options[:keys] = %w('~/.ssh/hoge_rsa')
ssh_options[:auth_methods] = %w(publickey)
ssh_options[:forward_agent] = true
default_run_options[:pty] = true
set :password, "sudo_password"
set :use_sudo, true

# assets precompile
namespace :assets do
  task :precompile, :roles => :web do
    run "cd #{current_path} && RAILS_ENV=production rake assets:precompile"
  end
end

namespace :deploy do
  task :set_file_process_owner do
    sudo "chown -R #{user}.#{user_group} #{deploy_to}"
  end
  
  desc "Change task status for passenger"
  task :restart, :roles => :web do
    sudo "touch #{current_path}/tmp/restart.txt"
  end
end

# deploy
before :deploy, "deploy:set_file_process_owner"
after :deploy, "maintenance:on"
after :deploy, "deploy:migrate"
after :deploy, "assets:precompile"
after :deploy, "deploy:restart"
after :deploy, "maintenance:off"
after :deploy, "deploy:cleanup"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
