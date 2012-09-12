# RVM bootstrap
#$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'
set :rvm_ruby_string, '1.9.3'
set :rvm_type, :user
# bundler bootstrap
require 'bundler/capistrano'

set :application, "softwarebajodemanda"
set :repository,  "git@github.com:ccastillop/software_bajo_demanda.git"
set :branch, "master"
#set :scm, :subversion
set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "softwarebajodemanda.com"#, "mailenvios.biz", "mailseminarium.com", "laborum.biz", "correo.gs1peru.com"
role :app, "softwarebajodemanda.com"#, "mailenvios.biz", "mailseminarium.com", "laborum.biz", "correo.gs1peru.com"
role :db,  "softwarebajodemanda.com",#, "mailenvios.biz", "mailseminarium.com", "laborum.biz", "correo.gs1peru.com",
     :primary => true

set :deploy_to, "/home/ccastillo/apps/software_bajo_demanda"

set :user,        "ccastillo"
set :use_sudo,    false

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts


# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      from = source.next_revision(current_revision)
      if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      else
        logger.info "Skipping asset pre-compilation because there were no asset changes"
      end
    end
  end
end

namespace(:customs) do
  task :config, :roles => :app do
    run <<-CMD
      ln -nfs #{shared_path}/database.yml #{release_path}/config/database.yml
    CMD
    run <<-CMD
      ln -nfs #{shared_path}/production.sqlite3 #{release_path}/db/production.sqlite3
    CMD
  end
  task :symlink, :roles => :app do
    run <<-CMD
      ln -nfs #{shared_path}/system/uploads #{release_path}/public/uploads
    CMD
  end
end

after "deploy:update_code", "customs:config"
after "deploy:update_code","customs:symlink"
#after "deploy", "deploy:assets:precompile"
after "deploy", "deploy:cleanup"

load 'deploy/assets'
