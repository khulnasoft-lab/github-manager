#
# Cookbook Name:: github_manager
# Recipe:: nginx
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

include_recipe 'nginx'

if node['github_manager']['http']['ssl']['enabled']
  ssl_data_bag = GithubManager::Helpers.load_data_bag(
    node['github_manager']['http']['ssl']['cert_databag'],
    node['github_manager']['http']['ssl']['cert_databag_item']
  )

  # Public key.
  file "/etc/ssl/certs/#{node['github_manager']['http']['host_name']}.crt" do
    mode 0644
    user 'root'
    group 'root'
    content "#{ssl_data_bag['cert']}"
    notifies :reload, 'service[nginx]', :delayed
  end

  # Private key.
  file "/etc/ssl/private/#{node['github_manager']['http']['host_name']}.key" do
    mode 0600
    user 'root'
    group 'root'
    content "#{ssl_data_bag['key']}"
    notifies :reload, 'service[nginx]', :delayed
  end
end

template ::File.join(node['nginx']['dir'], 'sites-available', 'github_manager') do
  source 'nginx-github-connector.conf.erb'
  notifies :reload, 'service[nginx]', :delayed
  mode 0644
  owner 'root'
  group 'root'
  action :create
  variables(
    :host_name          => node['github_manager']['http']['host_name'],
    :host_aliases       => node['github_manager']['http']['host_aliases'] || [],
    :ssl_enabled        => node['github_manager']['http']['ssl']['enabled'],
    :redirect_http      => node['github_manager']['http']['ssl']['enabled'],
    :listen_port        => node['github_manager']['http']['port'],
    :ssl_listen_port    => node['github_manager']['http']['ssl']['port'],
    :install_dir        => node['github_manager']['install_dir']
  )
end

nginx_site 'github_manager'
