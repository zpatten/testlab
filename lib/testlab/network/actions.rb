class TestLab
  class Network

    module Actions

      # Create the network
      def create
        @ui.logger.debug { "Network Create: #{self.id} " }

        please_wait(:ui => @ui, :message => format_object_action(self, 'Create', :green)) do
          self.node.ssh.exec(%(sudo brctl addbr #{self.bridge}), :silence => true, :ignore_exit_status => true)
        end
      end

      # Destroy the network
      def destroy
        @ui.logger.debug { "Network Destroy: #{self.id} " }

        please_wait(:ui => @ui, :message => format_object_action(self, 'Destroy', :red)) do
          self.node.ssh.exec(%(sudo brctl delbr #{self.bridge}), :silence => true, :ignore_exit_status => true)
        end
      end

      # Start the network
      def up
        @ui.logger.debug { "Network Up: #{self.id} " }

        please_wait(:ui => @ui, :message => format_object_action(self, 'Up', :green)) do
          self.node.ssh.exec(%(sudo ifconfig #{self.bridge} #{self.ip} up), :silence => true, :ignore_exit_status => true)
        end
      end

      # Stop the network
      def down
        @ui.logger.debug { "Network Down: #{self.id} " }

        please_wait(:ui => @ui, :message => format_object_action(self, 'Down', :red)) do
          self.node.ssh.exec(%(sudo ifconfig #{self.bridge} down), :silence => true, :ignore_exit_status => true)
        end
      end

    end

  end
end
