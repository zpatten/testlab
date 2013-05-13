class TestLab
  class Container

    module Actions

      # Create the container
      #
      # Builds the configuration for the container and sends a request to the
      # LXC sub-system to create the container.
      #
      # @return [Boolean] True if successful.
      def create
        @ui.logger.debug { "Container Create: #{self.id} " }

        please_wait(:ui => @ui, :message => format_object_action(self, 'Create', :green)) do
          self.domain  ||= self.node.labfile.config[:domain]
          self.distro  ||= "ubuntu"
          self.release ||= "precise"

          self.arch    ||= detect_arch

          self.lxc.config.clear
          self.lxc.config['lxc.utsname'] = self.id
          self.lxc.config['lxc.arch'] = self.arch
          self.lxc.config.networks = build_lxc_network_conf(self.interfaces)
          self.lxc.config.save

          self.lxc.create(*create_args)

          # TODO: This needs to really go somewhere else:
          home_dir = ((self.node.user == "root") ? %(/root) : %(/home/#{self.node.user}))
          container_home_dir = File.join(self.lxc.fs_root, "/home/ubuntu")

          home_authkeys = File.join(home_dir, %(.ssh), %(authorized_keys))
          container_authkeys = File.join(container_home_dir, %(.ssh), %(authorized_keys))

          self.node.ssh.exec(%(mkdir -pv #{File.join(container_home_dir, %(.ssh))}))
          self.node.ssh.exec(%(sudo cp -v #{home_authkeys} #{container_authkeys}))
          self.node.ssh.exec(%(sudo chown -v 1000:1000 #{container_authkeys}))
          self.node.ssh.exec(%(sudo chmod -v 644 #{container_authkeys}))
        end

        true
      end

      # Destroy the container
      #
      # Sends a request to the LXC sub-system to destroy the container.
      #
      # @return [Boolean] True if successful.
      def destroy
        @ui.logger.debug { "Container Destroy: #{self.id} " }

        please_wait(:ui => @ui, :message => format_object_action(self, 'Destroy', :red)) do
          self.lxc.destroy
        end

        true
      end

      # Start the container
      #
      # Sends a request to the LXC sub-system to bring the container online.
      #
      # @return [Boolean] True if successful.
      def up
        @ui.logger.debug { "Container Up: #{self.id} " }

        (self.lxc.state == :not_created) and return false #raise ContainerError, "We can not online a non-existant container!"

        please_wait(:ui => @ui, :message => format_object_action(self, 'Up', :green)) do
          self.lxc.start
          self.lxc.wait(:running)

          (self.lxc.state != :running) and raise ContainerError, "The container failed to online!"

          # TODO: This needs to really go somewhere else:
          self.lxc.attach(%(/bin/bash -c 'grep "sudo\tALL=\(ALL:ALL\) ALL" /etc/sudoers && sed -i "s/sudo\tALL=\(ALL:ALL\) ALL/sudo\tALL=\(ALL:ALL\) NOPASSWD: ALL/" /etc/sudoers'))
        end

        true
      end

      # Stop the container
      #
      # Sends a request to the LXC sub-system to take the container offline.
      #
      # @return [Boolean] True if successful.
      def down
        @ui.logger.debug { "Container Down: #{self.id} " }

        (self.lxc.state == :not_created) and return false # raise ContainerError, "We can not offline a non-existant container!"

        please_wait(:ui => @ui, :message => format_object_action(self, 'Down', :red)) do
          self.lxc.stop
          self.lxc.wait(:stopped)

          (self.lxc.state != :stopped) and raise ContainerError, "The container failed to offline!"
        end

        true
      end

    end

  end
end
