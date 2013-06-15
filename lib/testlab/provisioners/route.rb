class TestLab

  class Provisioner

    # Route Provisioner Error Class
    class RouteError < ProvisionerError; end

    # Route Provisioner Class
    #
    # @author Zachary Patten <zachary AT jovelabs DOT com>
    class Route

      def initialize(config={}, ui=nil)
        @config = (config || Hash.new)
        @ui     = (ui     || TestLab.ui)

        @config[:route] ||= Hash.new

        @ui.logger.debug { "config(#{@config.inspect})" }
      end

      # Route Provisioner Network Setup
      def on_network_setup(network)
        manage_route(:add, network)

        true
      end

      # Route Provisioner Network Teardown
      def on_network_teardown(network)
        manage_route(:del, network)

        true
      end

      def manage_route(action, network)
        command = ZTK::Command.new(:ui => @ui, :silence => true, :ignore_exit_status => true)

        case RUBY_PLATFORM
        when /darwin/ then
          action = ((action == :del) ? :delete : :add)
          command.exec(%(sudo route #{action} -net #{TestLab::Utility.network(network.address)} #{network.node.ip} #{TestLab::Utility.netmask(network.address)}))
        when /linux/ then
          command.exec(%(sudo route #{action} -net #{TestLab::Utility.network(network.address)} netmask #{TestLab::Utility.netmask(network.address)} gw #{network.node.ip}))
        end
      end

    end

  end
end