lock "~> 3.11.0"

set :branch, "master"

set :application, "extract"
set :repo_url, "git@github.com:feedbin/#{fetch(:application)}.git"
set :deploy_to, "/srv/apps/#{fetch(:application)}"
set :log_level, :warn

append :linked_dirs, "users", "node_modules", "deploy"

namespace :app do

  desc "Start processes"
  task :start do
    on roles(:app) do |host|
      within release_path do
        execute :sudo, :service, :extract, :restart
      end
    end
  end

  desc "Restart processes"
  task :restart do
    on roles(:app), in: :sequence, wait: 2 do |host|
      within release_path do
        execute :sudo, :service, :extract, :restart
      end
    end
  end

  desc "Bootstrap app"
  task :bootstrap do
    on roles(:app) do
      within release_path do
        execute "script/bootstrap.sh"
      end
    end
  end

  desc "Add user"
  task :add_user do
    on roles(:app) do
      within release_path do
        execute :echo, "#{ENV['password']} > users/#{ENV['user']}"
      end
    end
  end

end

after "deploy:updated", "app:bootstrap"
after "deploy:published", "app:restart"