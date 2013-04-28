class TestLab

  # Node Error Class
  class NodeError < TestLabError; end

  # Node Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Node < ZTK::DSL::Base
    STATUS_KEYS   = %w(id instance_id state user ip port provider con net rtr).map(&:to_sym)

    # Sub-Modules
    autoload :Bind,          'testlab/node/bind'
    autoload :ClassMethods,  'testlab/node/class_methods'
    autoload :Lifecycle,     'testlab/node/lifecycle'
    autoload :LXC,           'testlab/node/lxc'
    autoload :MethodMissing, 'testlab/node/method_missing'
    autoload :Resolv,        'testlab/node/resolv'
    autoload :SSH,           'testlab/node/ssh'
    autoload :Status,        'testlab/node/status'

    include TestLab::Node::Bind
    extend  TestLab::Node::ClassMethods
    include TestLab::Node::Lifecycle
    include TestLab::Node::LXC
    include TestLab::Node::MethodMissing
    include TestLab::Node::Resolv
    include TestLab::Node::SSH
    include TestLab::Node::Status

    # Associations and Attributes
    belongs_to :labfile,    :class_name => 'TestLab::Lab'

    has_many   :routers,    :class_name => 'TestLab::Router'
    has_many   :containers, :class_name => 'TestLab::Container'
    has_many   :networks,   :class_name => 'TestLab::Network'

    attribute  :provider
    attribute  :config
    attribute  :components


    def initialize(*args)
      super(*args)

      @ui       = TestLab.ui
      @provider = self.provider.new(self.config)
    end

  end

end
