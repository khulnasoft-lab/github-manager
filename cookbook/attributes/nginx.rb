default['nginx']['default_site_enabled'] = false

default['github_manager']['http']['host_name'] = node['fqdn']
default['github_manager']['http']['host_aliases'] = []
default['github_manager']['http']['port'] = 80
default['github_manager']['http']['ssl']['port'] = 443
default['github_manager']['http']['ssl']['enabled'] = true

# The cert databag should have `cert` and `key` keys
default['github_manager']['http']['ssl']['cert_databag'] = 'github_manager'
default['github_manager']['http']['ssl']['cert_databag_item'] = 'ssl_cert'
