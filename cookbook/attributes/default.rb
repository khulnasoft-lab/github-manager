default['github_manager']['user'] = 'github'
default['github_manager']['group'] = node['github_manager']['user']
default['github_manager']['install_dir'] = '/var/www/github-connector'

default['github_manager']['repo']['url'] = 'https://github.com/khulnasoft-lab/github-connector.git'
default['github_manager']['repo']['revision'] = 'v0.1.5'

# The secrets databag can contain the following keys:
#   * database_password
#   * database_key
#   * secrets_key_base
default['github_manager']['secrets_databag'] = 'github_manager'
default['github_manager']['secrets_databag_item'] = 'secrets'
default['github_manager']['secrets'] = {}
