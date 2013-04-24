class TestLab

  # Container Error Class
  class ContainerError < TestLabError; end

  # Container Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Container < ZTK::DSL::Base
    STATUS_KEYS   = %w(node_id id state distro release interfaces provisioner).map(&:to_sym)

    belongs_to  :node,        :class_name => 'TestLab::Node'

    attribute   :provisioner
    attribute   :config

    attribute   :interfaces

    attribute   :distro
    attribute   :release
    attribute   :arch

    attribute   :persist

    def initialize(*args)
      super(*args)

      @ui          = TestLab.ui
      @provisioner = self.provisioner.new(self.config) if !self.provisioner.nil?
    end

    def status
      interfaces = self.interfaces.collect{ |key, value| "#{key}:#{value[:name]}:#{value[:ip]}" }.join(', ')
      {
        :id => self.id,
        :state => self.state,
        :distro => self.distro,
        :release => self.release,
        :interfaces => interfaces,
        :provisioner => self.provisioner,
        :node_id => self.node.id
      }
    end

    # Our LXC Container class
    def lxc
      @lxc ||= self.node.lxc.container(self.id)
    end

    # Create the container
    def create
      @ui.logger.debug { "Container Create: #{self.id} " }

      self.arch ||= detect_arch

      self.lxc.create(*create_args)
    end

    # Destroy the container
    def destroy
      @ui.logger.debug { "Container Destroy: #{self.id} " }

      self.lxc.destroy
    end

    # Start the container
    def up
      @ui.logger.debug { "Container Up: #{self.id} " }

      self.lxc.start
    end

    # Stop the container
    def down
      @ui.logger.debug { "Container Down: #{self.id} " }

      self.lxc.stop
    end

    # Reload the container
    def reload
      @ui.logger.debug { "Container Reload: #{self.id} " }

      self.down
      self.up
    end

    # Does the container exist?
    def exists?
      @ui.logger.debug { "Container Exists?: #{self.id} " }

      self.lxc.exists?
    end

    # State of the container
    def state
      self.lxc.state
    end

################################################################################

    # Container Callback: after_create
    def after_create
      @ui.logger.debug { "Container Callback: After Create: #{self.id} " }
    end

    # Container Callback: after_up
    def after_up
      @ui.logger.debug { "Container Callback: After Up: #{self.id} " }

      self.create
      self.up
    end

    # Container Callback: before_down
    def before_down
      @ui.logger.debug { "Container Callback: Before Down: #{self.id} " }

      self.down
      self.destroy
    end

    # Container Callback: before_destroy
    def before_destroy
      @ui.logger.debug { "Container Callback: Before Destroy: #{self.id} " }
    end

################################################################################

    # Method missing handler
    def method_missing(method_name, *method_args)
      @ui.logger.debug { "CONTAINER METHOD MISSING: #{method_name.inspect}(#{method_args.inspect})" }

      if (defined?(@provisioner) && @provisioner.respond_to?(method_name))
        @provisioner.send(method_name, [self, *method_args].flatten)
      else
        super(method_name, *method_args)
      end
    end

################################################################################
  private
################################################################################

    # Returns arguments for lxc-create based on our distro
    def create_args
      case self.distro.downcase
      when "ubuntu" then
        %W(-f /etc/lxc/#{self.id} -t #{self.distro} -- --release #{self.release} --arch #{arch})
      when "fedora" then
        %W(-f /etc/lxc/#{self.id} -t #{self.distro} -- --release #{self.release})
      end
    end

    # Attempt to detect the architecture of the node our container is running on
    def detect_arch
      case self.distro.downcase
      when "ubuntu" then
        ((self.node.arch =~ /x86_64/) ? "amd64" : "i386")
      when "fedora" then
        ((self.node.arch =~ /x86_64/) ? "amd64" : "i686")
      end
    end

    def generate_ip
      octets = [ 192..192,
                 168..168,
                 0..254,
                 1..254 ]
      ip = Array.new
      for x in 1..4 do
        ip << octets[x-1].to_a[rand(octets[x-1].count)].to_s
      end
      ip.join(".")
    end

    def generate_mac
      digits = [ %w(0),
                 %w(0),
                 %w(0),
                 %w(0),
                 %w(5),
                 %w(e),
                 %w(0 1 2 3 4 5 6 7 8 9 a b c d e f),
                 %w(0 1 2 3 4 5 6 7 8 9 a b c d e f),
                 %w(5 6 7 8 9 a b c d e f),
                 %w(3 4 5 6 7 8 9 a b c d e f),
                 %w(0 1 2 3 4 5 6 7 8 9 a b c d e f),
                 %w(0 1 2 3 4 5 6 7 8 9 a b c d e f) ]
      mac = ""
      for x in 1..12 do
        mac += digits[x-1][rand(digits[x-1].count)]
        mac += ":" if (x.modulo(2) == 0) && (x != 12)
      end
      mac
    end

  end

end
