# Copyright 2016 SUSE Linux GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module SaharaHelper
  class << self
    def network_settings(node)
      @ip ||= Chef::Recipe::Barclamp::Inventory.get_network_by_type(node, "admin").address
      @cluster_admin_ip ||= nil

      if node[:sahara][:ha][:enabled] && !@cluster_admin_ip
        @cluster_admin_ip = CrowbarPacemakerHelper.cluster_vip(node, "admin")
      end

      @network_settings ||= {
        ip: @ip,

        api: {
          bind_host: if !node[:sahara][:ha][:enabled] && node[:sahara][:api][:bind_open_address]
                       "0.0.0.0"
                     else
                       @ip
                     end,
          bind_port: if node[:sahara][:ha][:enabled]
                       node[:sahara][:ha][:ports][:api_port].to_i
                     else
                       node[:sahara][:api][:bind_port].to_i
                     end,
          ha_bind_host: node[:sahara][:api][:bind_open_address] ? "0.0.0.0" : @cluster_admin_ip,
          ha_bind_port: node[:sahara][:api][:bind_port].to_i
        }
      }
    end
  end
end
