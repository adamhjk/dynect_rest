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
  class Resource

    attr_accessor :dynect, :fqdn, :record_type, :record_id, :ttl, :zone, :rdata

    def initialize(dynect, record_type, zone, fqdn=nil, record_id=nil, ttl=nil, rdata={})
      @dynect = dynect
      @record_type = record_type
      @fqdn = fqdn
      @record_id = record_id
      @ttl = ttl
      @zone = zone
      @rdata = rdata
    end

    def [](rdata_key)
      @rdata[rdata_key]
    end

    def []=(rdata_key, rdata_value)
      @rdata[rdata_key] = rdata_value
    end

    def fqdn(value=nil)
      value ? (@fqdn = value; self) : @fqdn
    end

    def record_id(value=nil)
      value ? (@record_id = value; self) : @record_id
    end

    def ttl(value=nil)
      value ? (@ttl = value; self) : @ttl
    end

    def resource_path(full=false)
      @record_type << "Record" unless @record_type[-6,6] == "Record"
      if (full == true || full == :full)
        "/REST/#{@record_type}/#{@zone}"
      else
        "#{@record_type}/#{@zone}"
      end
    end

    def get(fqdn = nil, record_id=nil)
      if record_id && fqdn
        raw_rr = @dynect.get("#{resource_path}/#{fqdn}/#{record_id}")
        DynectRest::Resource.new(dynect,
                                 raw_rr["record_type"],
                                 raw_rr["zone"],
                                 raw_rr["fqdn"],
                                 raw_rr["record_id"],
                                 raw_rr["ttl"],
                                 raw_rr["rdata"])
      elsif fqdn
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
      [get(fqdn)].flatten.each do |rr|
        query_hash.each do |key, value|
          results << rr if rr[key.to_s] == value
        end
      end
      results
    end

    def save(replace=false)
      if record_id
        @dynect.put("#{resource_path}/#{@fqdn}/#{record_id}", self)
      else
        if replace == true || replace == :replace
          @dynect.put("#{resource_path}/#{@fqdn}", self)
        else
          @dynect.post("#{resource_path}/#{@fqdn}", self)
        end
      end
      self
    end

    def delete
      url = if record_id
              "#{resource_path}/#{fqdn}/#{record_id}"
            else
              "#{resource_path}/#{fqdn}"
            end
      @dynect.delete(url)
    end

    def to_json
      {
        "rdata" => @rdata,
        "ttl"   => @ttl
      }.to_json
    end

    def method_missing(method_symbol, *args, &block)
      method_string = method_symbol.to_s
      if (args.length > 0 && method_string !~ /=$/)
        @rdata[method_string] = args.length == 1 ? args[0] : args
        self
      elsif @rdata.has_key?(method_string)
        @rdata[method_string]
      else
        raise NoMethodError, "undefined method `#{method_symbol.to_s}' for #{self.class.to_s}"
      end
    end

  end

end
