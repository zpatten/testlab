class TestLab

  # User Error Class
  class UserError < TestLabError; end

  # User Class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class User < ZTK::DSL::Base

    # Sub-Modules
    autoload :Lifecycle,     'testlab/user/lifecycle'

    include TestLab::User::Lifecycle

    # Associations and Attributes
    belongs_to  :container,  :class_name => 'TestLab::Container'

    attribute   :password

    attribute   :identity

    attribute   :uid
    attribute   :gid

    attribute   :primary,    :default => false

    def initialize(*args)
      super(*args)

      @ui = TestLab.ui
    end

  end

end
