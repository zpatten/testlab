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

# NETWORKS
###########
desc 'Manage networks'
arg_name 'Describe arguments to network here'
command :network do |c|

  c.desc 'Network ID or Name'
  c.arg_name 'network'
  c.flag [:n, :name]

  # NETWORK CREATE
  #################
  c.desc 'Create a network'
  c.long_desc <<-EOF
Create a network.  The network is created.
EOF
  c.command :create do |create|
    create.action do |global_options, options, args|
      if options[:name].nil?
        help_now!('a name is required') if options[:name].nil?
      else
        network = @testlab.networks.select{ |c| c.id.to_sym == options[:name].to_sym }.first
        network.nil? and raise TestLab::TestLabError, "We could not find the network you screateplied!"

        network.create
      end
    end
  end

  # NETWORK DESTROY
  #################
  c.desc 'Destroy a network'
  c.long_desc <<-EOF
Destroy a network.  The network is destroyed.
EOF
  c.command :destroy do |destroy|
    destroy.action do |global_options, options, args|
      if options[:name].nil?
        help_now!('a name is required') if options[:name].nil?
      else
        network = @testlab.networks.select{ |c| c.id.to_sym == options[:name].to_sym }.first
        network.nil? and raise TestLab::TestLabError, "We could not find the network you supplied!"

        network.destroy
      end
    end
  end

  # NETWORK UP
  #############
  c.desc 'Up a network'
  c.long_desc <<-EOF
Up a network.  The network is started and brought online.
EOF
  c.command :up do |up|
    up.action do |global_options, options, args|
      if options[:name].nil?
        help_now!('a name is required') if options[:name].nil?
      else
        network = @testlab.networks.select{ |c| c.id.to_sym == options[:name].to_sym }.first
        network.nil? and raise TestLab::TestLabError, "We could not find the network you supplied!"

        network.up
      end
    end
  end

  # NETWORK DOWN
  ###############
  c.desc 'Down a network'
  c.long_desc <<-EOF
Down a network.  The network is stopped taking it offline.
EOF
  c.command :down do |down|
    down.action do |global_options, options, args|
      if options[:name].nil?
        help_now!('a name is required') if options[:name].nil?
      else
        network = @testlab.networks.select{ |c| c.id.to_sym == options[:name].to_sym }.first
        network.nil? and raise TestLab::TestLabError, "We could not find the network you supplied!"

        network.down
      end
    end
  end

  # NETWORK SETUP
  ################
  c.desc 'Setup a network'
  c.long_desc <<-EOF
Setup a network.  The network is created, started and provisioned.
EOF
  c.command :setup do |setup|
    setup.action do |global_options, options, args|
      if options[:name].nil?
        help_now!('a name is required') if options[:name].nil?
      else
        network = @testlab.networks.select{ |c| c.id.to_sym == options[:name].to_sym }.first
        network.nil? and raise TestLab::TestLabError, "We could not find the network you supplied!"

        network.setup
      end
    end
  end

  # NETWORK TEARDOWN
  ###################
  c.desc 'Teardown a network'
  c.long_desc <<-EOF
Teardown a network.  The network is offlined and destroyed.
EOF
  c.command :teardown do |teardown|
    teardown.action do |global_options, options, args|
      if options[:name].nil?
        help_now!('a name is required') if options[:name].nil?
      else
        network = @testlab.networks.select{ |c| c.id.to_sym == options[:name].to_sym }.first
        network.nil? and raise TestLab::TestLabError, "We could not find the network you supplied!"

        network.teardown
      end
    end
  end

  # NETWORK STATUS
  #################
  c.desc 'Display the status of network(s)'
  c.long_desc <<-EOF
Displays the status of all networks or a single network if supplied via the ID parameter.
EOF
  c.command :status do |status|
    status.action do |global_options, options, args|
      if options[:name].nil?
        # No ID supplied; show everything
        networks = @testlab.networks.delete_if{|n| n.node.dead? }
        if networks.count == 0
          @testlab.ui.stderr.puts("You either have no networks defined or dead nodes!".yellow)
        else
          ZTK::Report.new(:ui => @testlab.ui).spreadsheet(networks, TestLab::Network::STATUS_KEYS) do |network|
            OpenStruct.new(network.status)
          end
        end
      else
        # ID supplied; show just that item
        network = @testlab.networks.select{ |c| c.id.to_sym == options[:name].to_sym }.first
        network.nil? and raise TestLab::TestLabError, "We could not find the network you supplied!"

        ZTK::Report.new(:ui => @testlab.ui).list(network, TestLab::Network::STATUS_KEYS) do |network|
          OpenStruct.new(network.status)
        end
      end
    end
  end

  # ROUTES
  #########
  c.desc 'Manage routes'
  c.command :route do |route|

    # ROUTE ADD
    ############
    route.desc 'Add routes to lab networks'
    route.command :add do |add|
      add.action do |global_options,options,args|
        help_now!('a name is required') if options[:name].nil?

        network = @testlab.networks.select{ |c| c.id.to_sym == options[:name].to_sym }.first
        network.nil? and raise TestLab::TestLabError, "We could not find the network you supplied!"

        network.manage_route(:add)
        @testlab.ui.stdout.puts("Added routes successfully!".green.bold)
        @testlab.ui.stdout.puts %x(netstat -nr | grep '#{network.node.ip}').strip
      end
    end

    # ROUTE DEL
    ############
    route.desc 'Delete routes to lab networks'
    route.command :del do |del|
      del.action do |global_options,options,args|
        help_now!('a name is required') if options[:name].nil?

        network = @testlab.networks.select{ |c| c.id.to_sym == options[:name].to_sym }.first
        network.nil? and raise TestLab::TestLabError, "We could not find the network you supplied!"

        network.manage_route(:del)
        @testlab.ui.stdout.puts("Deleted routes successfully!".red.bold)
        @testlab.ui.stdout.puts %x(netstat -nr | grep '#{network.node.ip}').strip
      end
    end

    # ROUTE SHOW
    #############
    route.desc 'Show routes to lab networks'
    route.command :show do |show|
      show.action do |global_options,options,args|
        help_now!('a name is required') if options[:name].nil?

        network = @testlab.networks.select{ |c| c.id.to_sym == options[:name].to_sym }.first
        network.nil? and raise TestLab::TestLabError, "We could not find the network you supplied!"

        @testlab.ui.stdout.puts("TestLab routes:".green.bold)
        case RUBY_PLATFORM
        when /darwin/ then
          @testlab.ui.stdout.puts %x(netstat -nrf inet | grep '#{network.node.ip}').strip
        when /linux/ then
          @testlab.ui.stdout.puts %x(netstat -nr | grep '#{network.node.ip}').strip
        end
      end
    end
  end

end