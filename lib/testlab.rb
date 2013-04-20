require 'ztk'

require 'testlab/version'

# Top-Level LXC Class
#
# @author Zachary Patten <zachary@jovelabs.net>
class TestLab

  # Top-Level Error Class
  class TestLabError < StandardError; end

  autoload :Provider, 'testlab/provider'
  autoload :Provisioner, 'testlab/provisioner'

  autoload :Labfile, 'testlab/labfile'
  autoload :Node, 'testlab/node'
  autoload :Router, 'testlab/router'
  autoload :Container, 'testlab/container'
  autoload :Network, 'testlab/network'
  autoload :Link, 'testlab/link'

  @@ui ||= nil

  def initialize(ui=ZTK::UI.new)
    labfile = ZTK::Locator.find('Labfile')

    @@ui          = ui
    @labfile      = TestLab::Labfile.load(labfile)
  end

  # def nodes
  #   TestLab::Node.all
  # end

  # def containers
  #   TestLab::Container.all
  # end

  # def networks
  #   TestLab::Network.all
  # end

  # def config
  #   @labfile.config
  # end

  def status
    ZTK::Report.new.spreadsheet(TestLab::Node.all, TestLab::Provider::STATUS_KEYS) do |node|
      OpenStruct.new(node.status)
    end
  end

  # Proxy various method calls to our subordinate classes
  def method_missing(method_name, *method_args)
    puts("TESTLAB METHOD_MISSING -- #{method_name.inspect} -- #{method_args.inspect}")

    if TestLab::Provider::PROXY_METHODS.include?(method_name)
      @@ui.logger.debug { "TestLab.#{method_name}" }
      TestLab::Node.all.map do |node|
        node.send(method_name.to_sym, *method_args)
      end
    else
      super(method_name, *method_args)
    end
  end

  # Class Helpers
  class << self

    def ui
      @@ui ||= ZTK::UI.new
    end

    def gem_dir
      directory = File.join(File.dirname(__FILE__), "..")
      File.expand_path(directory, File.dirname(__FILE__))
    end

    def build_command(name, *args)
      executable = (ZTK::Locator.find('bin', name) rescue "/bin/env #{name}")
      [executable, args].flatten.compact.join(' ')
    end

  end

end
