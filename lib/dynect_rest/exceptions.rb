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
  class Exceptions
    class RequestFailed < RuntimeError; end
    # we need to handle API calls that return a status of 'incomplete' and return the job_id
    class IncompleteRequest < RuntimeError
      attr_reader :job_id, :message

      def initialize(message, job_id)
        @message = message
        @job_id = job_id
      end
    end
  end
end
