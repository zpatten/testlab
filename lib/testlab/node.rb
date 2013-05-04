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

  # Node Error Class
  class NodeError < TestLabError; end

  # Node Class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class Node < ZTK::DSL::Base
    STATUS_KEYS   = %w(id instance_id state user ip port provider con net).map(&:to_sym)

    # Sub-Modules
    autoload :Actions,       'testlab/node/actions'
    autoload :Bind,          'testlab/node/bind'
    autoload :ClassMethods,  'testlab/node/class_methods'
    autoload :Lifecycle,     'testlab/node/lifecycle'
    autoload :LXC,           'testlab/node/lxc'
    autoload :MethodMissing, 'testlab/node/method_missing'
    autoload :Resolv,        'testlab/node/resolv'
    autoload :SSH,           'testlab/node/ssh'
    autoload :Status,        'testlab/node/status'

    include TestLab::Node::Actions
    include TestLab::Node::Bind
    include TestLab::Node::Lifecycle
    include TestLab::Node::LXC
    include TestLab::Node::MethodMissing
    include TestLab::Node::Resolv
    include TestLab::Node::SSH
    include TestLab::Node::Status

    extend  TestLab::Node::ClassMethods

    include TestLab::Utility::Misc

    # Associations and Attributes
    belongs_to :labfile,    :class_name => 'TestLab::Lab'

    has_many   :containers, :class_name => 'TestLab::Container'
    has_many   :networks,   :class_name => 'TestLab::Network'

    attribute  :provider
    attribute  :config
    attribute  :components
    attribute  :route


    def initialize(*args)
      super(*args)

      @ui       = TestLab.ui
      @provider = self.provider.new(self.config, @ui)
    end

  end

end
