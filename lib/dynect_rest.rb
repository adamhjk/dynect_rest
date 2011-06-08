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

  require 'dynect_rest/exceptions'
  require 'dynect_rest/resource'
  require 'rest_client'
  require 'json'

  attr_accessor :customer_name, :user_name, :password, :rest, :zone

  # Creates a new base object for interacting with Dynect's REST API
  #
  # @param [String] Your dynect customer name
  # @param [String] Your dnyect user name
  # @param [String] Your dynect password
  # @param [String] The zone you are going to be editing
  # @param [Boolean] Whether to connect immediately or not - runs login for you
  def initialize(customer_name, user_name, password, zone=nil, connect=true)
    @customer_name = customer_name
    @user_name = user_name
    @password = password
    @rest = RestClient::Resource.new('https://api2.dynect.net/REST/', :headers => { :content_type => 'application/json' })
    @zone = zone 
    login if connect
  end

  ##
  # Session Management
  ## 
  
  # Login to Dynect - must be done before any other methods called.
  #
  # See: https://manage.dynect.net/help/docs/api2/rest/resources/Session.html
  #
  # @return [Hash] The dynect API response
  def login
    response = post('Session', { 'customer_name' => @customer_name, 'user_name' => @user_name, 'password' => @password })
    @rest.headers[:auth_token] = response["token"]
    response
  end

  # Logout of Dynect - must be done before any other methods called.
  #
  # See: https://manage.dynect.net/help/docs/api2/rest/resources/Session.html
  #
  # @return [Hash] The dynect API response
  def logout
    delete('Session')
  end

  ##
  # Zone
  ##
  # Get a zone from dynect
  #
  # See: https://manage.dynect.net/help/docs/api2/rest/resources/Zone.html
  #
  # @param [String] The zone to fetch - if one is provided when instantiated, we use that.
  # @return [Hash] The dynect API response
  def get_zone(zone=nil)  
    zone ||= @zone
    get("Zone/#{zone}")
  end

  # Publish any pending changes to the zone - required to make any alterations permanent.
  #
  # See: https://manage.dynect.net/help/docs/api2/rest/resources/Zone.html
  #
  # @param [String] The zone to publish - if one is provided when instantiated, we use that.
  # @return [Hash] The dynect API response
  def publish(zone=nil)
    zone ||= @zone 
    put("Zone/#{zone}", { "publish" => true })
  end

  # Freeze the zone.
  #
  # See: https://manage.dynect.net/help/docs/api2/rest/resources/Zone.html
  #
  # @param [String] The zone to freeze - if one is provided when instantiated, we use that.
  # @return [Hash] The dynect API response
  def freeze(zone=nil)
    zone ||= @zone 
    put("Zone/#{zone}", { "freeze" => true })
  end

  # Thaw the zone.
  #
  # See: https://manage.dynect.net/help/docs/api2/rest/resources/Zone.html
  #
  # @param [String] The zone to thaw - if one is provided when instantiated, we use that.
  # @return [Hash] The dynect API response
  def thaw(zone=nil)
    zone ||= @zone 
    put("Zone/#{zone}", { "thaw" => true })
  end

  # Convert a CamelCasedString to an under_scored_string.
  def self.underscore(string)
    word = string.dup
    word.gsub!(/::/, '/')
    word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end

  ##
  # Resource Records
  ##
  %w{AAAA A CNAME DNSKEY DS KEY LOC MX NS PTR RP SOA SRV TXT}.each do |record_type|
    define_method underscore(record_type) do
      DynectRest::Resource.new(self,"#{record_type}Record" , @zone)
    end
  end

  %w{Node NodeList}.each do |type|
    define_method underscore(type) do
      DynectRest::Resource.new(self,"#{type}" , @zone)
    end
  end

  # Raw GET request, formatted for Dyn. See list of endpoints at:
  #
  # https://manage.dynect.net/help/docs/api2/rest/resources/
  #
  # @param [String] The partial path to GET - for example, 'User' or 'Zone'.
  # @param [Hash] Additional HTTP headers
  def get(path_part, additional_headers = {}, &block)
    api_request { @rest[path_part].get(additional_headers, &block) }
  end

  # Raw DELETE request, formatted for Dyn. See list of endpoints at:
  #
  # https://manage.dynect.net/help/docs/api2/rest/resources/
  #
  # @param [String] The partial path to DELETE - for example, 'User' or 'Zone'.
  # @param [Hash] Additional HTTP headers
  def delete(path_part, additional_headers = {}, &block)
    api_request { @rest[path_part].delete(additional_headers, &block) }
  end

  # Raw POST request, formatted for Dyn. See list of endpoints at:
  #
  # https://manage.dynect.net/help/docs/api2/rest/resources/
  #
  # Read the API documentation, and submit the proper data structure from here.
  #
  # @param [String] The partial path to POST - for example, 'User' or 'Zone'.
  # @param [Hash] The data structure to submit as the body, is automatically turned to JSON.
  # @param [Hash] Additional HTTP headers
  def post(path_part, payload, additional_headers = {}, &block)
    api_request { @rest[path_part].post(payload.to_json, additional_headers, &block) }
  end

  # Raw PUT request, formatted for Dyn. See list of endpoints at:
  #
  # https://manage.dynect.net/help/docs/api2/rest/resources/
  #
  # Read the API documentation, and submit the proper data structure from here.
  #
  # @param [String] The partial path to PUT - for example, 'User' or 'Zone'.
  # @param [Hash] The data structure to submit as the body, is automatically turned to JSON.
  # @param [Hash] Additional HTTP headers
  def put(path_part, payload, additional_headers = {}, &block)
    api_request { @rest[path_part].put(payload.to_json, additional_headers, &block) }
  end

  # Handles making Dynect API requests and formatting the responses properly.
  def api_request(&block)
    response_body = begin
      response = block.call
      response.body
    rescue RestClient::Exception => e
      puts "I have #{e.inspect} with #{e.http_code}"
      if e.http_code == 307
        get(e.response)
      end
      e.response
    end
    parse_response(JSON.parse(response_body))
  end

  def parse_response(response)
    case response["status"]
    when "success"
      response["data"]
    when "failure", "incomplete"
      error_messages = []
      response["msgs"].each do |error_message|
        error_messages << "#{error_message["LVL"]} #{error_message["ERR_CD"]} #{error_message["SOURCE"]} - #{error_message["INFO"]}"
      end
      raise DynectRest::Exceptions::RequestFailed, "Request failed: #{error_messages.join("\n")}" 
    end
  end


end
