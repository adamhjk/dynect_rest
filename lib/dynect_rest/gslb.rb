#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.
# License:: Apache License, Version 2.0
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

class DynectRest
  class GSLB

    def initialize(init_hash)
      @dynect = init_hash[:dynect]
      @zone = init_hash[:zone]
      @fqdn = init_hash.has_key?(:fqdn) ? init_hash[:fqdn] : nil
      @ttl = init_hash.has_key?(:ttl) ? init_hash[:ttl] : 30
      @host_list = init_hash.has_key?(:host_list) ? init_hash[:host_list] : {}
      @contact_nick = init_hash.has_key?(:contact_nick) ? init_hash[:contact_nick] : 'owner'
      
      @region_code = init_hash.has_key?(:region_code) ? init_hash[:region_code] : 'global'
      @monitor = init_hash.has_key?(:monitor) ? init_hash[:monitor] : {}
      @serve_count = init_hash.has_key?(:serve_count) ? init_hash[:serve_count] : 1
      @min_healthy = init_hash.has_key?(:min_healthy) ? init_hash[:min_healthy] : 1
    end

    def [](host_list_key)
      @host_list[host_list_key]
    end

    def fqdn(value=nil)
      value ? (@fqdn = value; self) : @fqdn
    end

    def ttl(value=nil)
      value ? (@ttl = value; self) : @ttl
    end

    def region_code(value=nil)
      # US West, US Central, US East, EU West, EU Central, EU East, Asia, global
      value ? (@region_code = value; self) : @region_code
    end

    def host_list(value=nil)
      value ? (@host_list = value; self) : @host_list
    end

    def monitor(value=nil)
      # :protocol => 'HTTP', :interval => 1, :retries => 2, :timeout => 10, :port => 8000,
      # :path => '/healthcheck', :host => 'example.com', :header => 'X-User-Agent: DynECT Health\n', :expected => 'passed'
      value ? (@monitor = value; self) : @monitor
    end

    def add_host(value)
      # :address => 'x.x.x.x', :label => 'friendly-name', :weight => 10, :serve_mode => 'obey'
      @host_list[value[:address]] = value
      self
    end

    def resource_path(full=false)
      @service_type = "GSLB"
      if (full == true || full == :full)
        "/REST/#{@service_type}/#{@zone}"
      else
        "#{@service_type}/#{@zone}"
      end
    end

    def get(fqdn = nil)
      if fqdn
        results = @dynect.get("#{resource_path}/#{fqdn}")
        raw_rr_list = results.map do |record|
          if (record =~ /^#{resource_path(:full)}\/#{Regexp.escape(fqdn)}\/(\d+)$/)
            self.get(fqdn, $1)
          else
            record
          end
        end
        case raw_rr_list.length
        when 0
          raise DynectRest::Exceptions::RequestFailed, "Cannot find #{record_type} record for #{fqdn}"
        when 1
          raw_rr_list[0]
        else
          raw_rr_list
        end
      else
        @dynect.get(resource_path)
      end
    end

    def find(fqdn, query_hash)
      results = []
      get(fqdn).each do |rr|
        query_hash.each do |key, value|
          results << rr if rr[key.to_s] == value
        end
      end
      results
    end

    def save(replace=false)
      if replace == true || replace == :replace
        @dynect.put("#{resource_path}/#{@fqdn}", self)
      else
        @dynect.post("#{resource_path}/#{@fqdn}", self)
      end
      self
    end

    def delete
      @dynect.delete("#{resource_path}/#{fqdn}")
    end

    def to_json
      {
        "ttl"   => @ttl,
        "monitor" => @monitor,
        "region" => {
          "region_code" => @region_code,
          "serve_count" => @serve_count,
          "min_healthy" => @min_healthy,
          "pool" => @host_list.values
        },
        "contact_nickname" => @contact_nick
      }.to_json
    end
  end
end
