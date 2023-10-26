default['github_manager']['ruby_version'] = 'ruby-2.3.0'
default['github_manager']['ruby_gemset'] = 'github-connector'
default['github_manager']['rvm_alias'] = 'github-connector'

default['rvm']['version'] = '1.26.11'
default['rvm']['user_rubies'] = [node['github_manager']['ruby_version']]
default['rvm']['user_default_ruby'] = node['github_manager']['ruby_version']
default['rvm']['user_autolibs'] = 'read-fail'
