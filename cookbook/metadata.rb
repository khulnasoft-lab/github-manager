name             'github_manager'
maintainer       "KhulnaSoft, Inc."
maintainer_email "engineeringservices@khulnasoft-lab.com"
license          "Apache v2.0"
description      "Installs and configures the GitHub Active Directory Connector"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url       "https://github.com/khulnasoft-lab/github-connector/tree/master/cookbook"
issues_url       "https://github.com/khulnasoft-lab/github-connector/issues"
version          "0.1.7"

supports 'ubuntu'

depends 'apt', '>= 2.3.10'
depends 'database', '>= 2.0'
depends 'logrotate', '>= 1.7.0'
depends 'nginx', '>= 2.0'
# postgres 4.0 cookbook introduces changes that haven't been tested.
depends 'postgresql', '~> 3.4'
depends 'ssh_known_hosts'

# rvm is a khulnasoft-lab patched version, see Berksfile
depends 'rvm', '= 0.9.0'
