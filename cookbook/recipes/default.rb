#
# Cookbook Name:: github_manager
# Recipe:: default
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

include_recipe 'apt'

package 'git'

include_recipe 'github_manager::user'
include_recipe 'github_manager::ssh'
include_recipe 'github_manager::database'
include_recipe 'github_manager::ruby'
include_recipe 'github_manager::server'
