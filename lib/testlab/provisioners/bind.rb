class TestLab

  class Provisioner

    # Bind Provisioner Error Class
    class BindError < ProvisionerError; end

    # Bind Provisioner Class
    #
    # @author Zachary Patten <zachary AT jovelabs DOT com>
    class Bind

      def initialize(config={}, ui=nil)
        @config = (config || Hash.new)
        @ui     = (ui     || TestLab.ui)

        @config[:bind] ||= Hash.new

        @ui.logger.debug { "config(#{@config.inspect})" }
      end

      # Bind Provisioner Node Setup
      #
      # @param [TestLab::Node] node The node which we want to provision.
      # @return [Boolean] True if successful.
      def node(node)
        @ui.logger.debug { "BIND Provisioner: Node #{node.id}" }

        bind_setup(node.ssh)

        true
      end

      # Builds the main bind configuration sections
      def build_bind_main_partial(file)
        bind_conf_template = File.join(TestLab::Provisioner.template_dir, "bind", "bind.erb")

        file.puts(ZTK::Template.do_not_edit_notice(:message => "TestLab v#{TestLab::VERSION} BIND Configuration", :char => '//'))
        file.puts(ZTK::Template.render(bind_conf_template, {}))
      end

      def build_bind_records
        forward_records = Hash.new
        reverse_records = Hash.new

        TestLab::Container.all.each do |container|
          container.domain ||= container.node.labfile.config[:domain]

          container.interfaces.each do |interface|
            forward_records[container.domain] ||= Array.new
            forward_records[container.domain] << %(#{container.id} IN A #{interface.ip})

            reverse_records[interface.network_id] ||= Array.new
            reverse_records[interface.network_id] << %(#{interface.ptr} IN PTR #{container.fqdn}.)
          end

        end
        { :forward => forward_records, :reverse => reverse_records }
      end

      # Builds the bind configuration sections for our zones
      def build_bind_zone_partial(ssh, file)
        bind_zone_template = File.join(TestLab::Provisioner.template_dir, "bind", 'bind-zone.erb')

        bind_records = build_bind_records
        forward_records = bind_records[:forward]
        reverse_records = bind_records[:reverse]

        TestLab::Network.all.each do |network|
          context = {
            :zone => network.arpa
          }

          file.puts
          file.puts(ZTK::Template.render(bind_zone_template, context))

          build_bind_db(ssh, network.arpa, reverse_records[network.id])
        end

        TestLab::Container.domains.each do |domain|
          context = {
            :zone => domain
          }

          file.puts
          file.puts(ZTK::Template.render(bind_zone_template, context))

          build_bind_db(ssh, domain, forward_records[domain])
        end
      end

      def build_bind_db(ssh, zone, records)
        bind_db_template = File.join(TestLab::Provisioner.template_dir, "bind", 'bind-db.erb')

        ssh.file(:target => "/etc/bind/db.#{zone}", :chown => "bind:bind") do |file|
          file.puts(ZTK::Template.do_not_edit_notice(:message => "TestLab v#{TestLab::VERSION} BIND DB: #{zone}", :char => ';'))
          file.puts(ZTK::Template.render(bind_db_template, { :zone => zone, :records => records }))
        end
      end

      # Builds the BIND configuration
      def build_bind_conf(ssh)
        ssh.file(:target => File.join("/etc/bind/named.conf"), :chown => "bind:bind") do |file|
          build_bind_main_partial(file)
          build_bind_zone_partial(ssh, file)
        end
      end

      def bind_install(ssh)
        ssh.exec(%(sudo apt-get -y install bind9))
        ssh.exec(%(sudo rm -fv /etc/bind/{*.arpa,*.zone,*.conf*}))
      end

      def bind_reload(ssh)
        ssh.exec(%(sudo chown -Rv bind:bind /etc/bind))
        ssh.exec(%(sudo rndc reload))
      end

      def bind_setup(ssh)
        bind_install(ssh)
        build_bind_conf(ssh)
        bind_reload(ssh)
      end

    end

  end
end