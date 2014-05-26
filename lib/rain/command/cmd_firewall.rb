require 'rain/command/cmd_base'

require 'rain/action/real/list_firewall'
require 'rain/action/real/update_firewall'
require 'rain/action/model/list_firewall'


module Rain

  module Command

    class Firewall < Base

      acorn_handler [:show, :diff, :model, :create] => :acorn_default_handler


      def acorn_default_handler(orig_args)
        command, args = get_command(orig_args)
        options = {}
        debug { "Running command #{command} with args #{args.join(',')}" }

        case command
          when :show
            options = defaults_from_optparser(args, [:format])
            run(command, {}, options, args)

          when :diff
            options = defaults_from_optparser(args, [:format])
            return run(command, {}, options, args)

          when :model
            options = defaults_from_optparser(args, [:format])
            run(command, {}, options, args)

          when :create
            options = defaults_from_optparser(args, [:confirmcode])
            run(command, {}, options, args)

          else
            handle_others(orig_args, 'firewall', self.class.internal_commands, command)
        end
        0
      end


      def run(action, global_options, options, args)
        @options = options

        case action
          when :show
            zone    = get_object_from_param(args.first, :zone, [:zone, :env])
            action  = Rain::Action::Real::ListFirewall.new(args)
            results = action.execute(zone)
            output(:show, results)

          when :diff
            env           = get_object_from_param(args.first, :env, [:env])
            action        = Rain::Action::Model::ListFirewall.new(args)
            model_results = action.execute(env)

            zone         = get_object_from_param(args.first, :zone, [:env])
            action       = Rain::Action::Real::ListFirewall.new(args)
            live_results = action.execute(zone)

            generate_diff do |model_handle, live_handle|
              output(:model, model_results[:FirewallService], model_handle)
              output(:show, live_results, live_handle)
            end

          when :model
            env     = get_object_from_param(args.first, :env, [:model, :env])
            action  = Rain::Action::Model::ListFirewall.new(args)
            results = action.execute(env)
            output(:model, results[:FirewallService])

          when :create
            env     = get_object_from_param(args.first, :env, [:model, :env])
            env.zone.zone_check(@options)
            action  = Rain::Action::Real::UpdateFirewall.new(args)
            results = action.execute(env)
        end
      end


      def output(command, results, handle = $stdout)

        handle.puts "%-6s %-5s %-20s %-6s %-6s    %-20s %-6s %-s" %
                        ['', 'proto', 'source-ip', 'port', 'srange', 'dest-ip', 'drange', 'description']

        results[:FirewallRule].each do |row|
          proto  = row[:Protocols].select { |k, v| v = true }.keys.join(',')
          string = "%-6s %-5s %-20s %-6s %-6s    %-20s %-6s %-s" %
              [row[:Policy], proto,
               row[:SourceIp], row[:SourcePort], row[:SourcePortRange],
               row[:DestinationIp], row[:DestinationPortRange],
               row[:Description]]
          handle.puts string.downcase
        end

      end


    end

  end


end
