class TestLab

  # Provisioner Error Class
  class ProvisionerError < TestLabError; end

  # Provisioner Class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class Provisioner
    autoload :Shell,     'testlab/provisioners/shell'
    autoload :OmniBus,   'testlab/provisioners/omnibus'
    autoload :OmniTruck, 'testlab/provisioners/omnitruck'

    class << self

      # Returns the path to the gems provisioner templates
      def template_dir
        File.join(TestLab.gem_dir, "lib", "testlab", "provisioners", "templates")
      end

    end

  end

end
