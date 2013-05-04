################################################################################
#
#      Author: Zachary Patten <zachary AT jovelabs DOT com>
#   Copyright: Copyright (c) Zachary Patten
#     License: Apache License, Version 2.0
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
################################################################################
class TestLab
  class Node

    module Status

      # Node Status
      #
      # @return [Hash] A hash detailing the status of the node.
      def status
        {
          :id => self.id,
          :instance_id => @provider.instance_id,
          :state => @provider.state,
          :user => @provider.user,
          :ip => @provider.ip,
          :port => @provider.port,
          :provider => @provider.class,
          :con => self.containers.count,
          :net => self.networks.count
        }
      end

    end

  end
end
