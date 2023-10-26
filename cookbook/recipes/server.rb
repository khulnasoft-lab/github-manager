#
# Cookbook Name:: github_manager
# Recipe:: server
#
# Copyright (C) 2014 Brandon Turner
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# Install Directory
#

install_dir = node['github_manager']['install_dir']
ruby_string = "#{node['github_manager']['ruby_version']}@#{node['github_manager']['ruby_gemset']}"

directory File.dirname(install_dir) do
  recursive true
end

directory install_dir do
  mode 0755
  owner node['github_manager']['user']
  group node['github_manager']['group']
end

#
# Source code
#

git 'github-connector' do
  destination install_dir
  user node['github_manager']['user']
  group node['github_manager']['group']
  repository node['github_manager']['repo']['url']
  revision node['github_manager']['repo']['revision']
  ssh_wrapper "/home/#{node['github_manager']['user']}/.ssh/github_manager_ssh_wrapper.sh"
  action :sync
  # Notify configuration files immediately so they are available before
  # migrating database
  notifies :create, 'template[github-connector-databaseyml]', :immediately
  notifies :create, 'template[github-connector-secretsyml]', :immediately
  notifies :reload, 'service[github-connector-web]', :delayed
  notifies :restart, 'service[github-connector-worker]', :delayed
end

#
# Custom engines
#

directory "#{install_dir}/vendor/engines" do
  recursive true
  owner node['github_manager']['user']
  group node['github_manager']['group']
end

node['github_manager']['engines'].each do |engine, attrs|
  git engine do
    destination "#{install_dir}/vendor/engines/#{engine}"
    user node['github_manager']['user']
    group node['github_manager']['group']
    repository attrs['url']
    revision attrs['revision']
    ssh_wrapper "/home/#{node['github_manager']['user']}/.ssh/#{engine}_ssh_wrapper.sh"
    action :sync
    notifies :run, 'rvm_shell[github-connector-gems]', :immediately
    notifies :run, 'rvm_shell[github-connector-database-migration]', :immediately
    notifies :run, 'rvm_shell[github-connector-assets]', :immediately
    notifies :reload, 'service[github-connector-web]', :delayed
    notifies :restart, 'service[github-connector-worker]', :delayed
  end
end


# Create an alias that remains consistent across version/gemset changes
execute 'github-connector-alias' do
  rvm_cmd = "/home/#{node['github_manager']['user']}/.rvm/bin/rvm"
  rvm_alias = node['github_manager']['rvm_alias']
  ruby_string = "#{node['github_manager']['ruby_version']}@#{node['github_manager']['ruby_gemset']}"

  user node['github_manager']['user']
  group node['github_manager']['group']
  command "#{rvm_cmd} alias create #{rvm_alias} #{ruby_string}"
  not_if do
    cmd = Mixlib::ShellOut.new("#{rvm_cmd} alias show #{rvm_alias}")
    cmd.run_command
    !cmd.error? && (cmd.stdout.strip == ruby_string)
  end
  notifies :reload, 'service[github-connector-web]', :delayed
  notifies :restart, 'service[github-connector-worker]', :delayed
end

#
# Configuration files
#

template 'github-connector-databaseyml' do
  path ::File.join(install_dir, 'config', 'database.yml')
  mode 0600
  owner node['github_manager']['user']
  group node['github_manager']['group']
  source 'database.yml.erb'
  only_if { ::File.directory?(::File.join(install_dir, 'config')) }
end

template 'github-connector-secretsyml' do
  path ::File.join(install_dir, 'config', 'secrets.yml')
  mode 0600
  owner node['github_manager']['user']
  group node['github_manager']['group']
  source 'secrets.yml.erb'
  only_if { ::File.directory?(::File.join(install_dir, 'config')) }
end


#
# Install gems
#

rvm_shell 'github-connector-gems' do
  ruby_string ruby_string
  user node['github_manager']['user']
  group node['github_manager']['group']
  cwd install_dir
  code %{bundle install}
  action :nothing
  subscribes :run, 'git[github-connector]', :immediately
  subscribes :run, 'execute[github-connector-alias]', :immediately
end

#
# Migrate database
#

rvm_shell 'github-connector-database-migration' do
  ruby_string ruby_string
  user node['github_manager']['user']
  group node['github_manager']['group']
  cwd install_dir
  code %{rake db:migrate RAILS_ENV=production}
  action :nothing
  subscribes :run, 'git[github-connector]', :immediately
end

#
# Compile assets
#

rvm_shell 'github-connector-assets' do
  ruby_string ruby_string
  user node['github_manager']['user']
  group node['github_manager']['group']
  cwd install_dir
  code %{rake assets:precompile RAILS_ENV=production}
  action :nothing
  subscribes :run, 'git[github-connector]', :immediately
end

# Logrotate
include_recipe 'logrotate'
logrotate_app 'github-connector' do
  path "#{install_dir}/log/*.log"
  create "0644 #{node['github_manager']['user']} #{node['github_manager']['group']}"
  options %w(missingok delaycompress notifempty copytruncate)
end

# Nginx proxy
include_recipe 'github_manager::nginx'

# Upstart services
include_recipe 'github_manager::upstart'

# Cron
include_recipe 'github_manager::cron'
