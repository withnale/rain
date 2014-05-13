require 'rain/command/cmd_base'

require 'rain/action/real/list_firewall'
require 'rain/action/real/update_firewall'
require 'rain/action/model/list_firewall'


module Rain

  module Command

    class Firewall < Base


      def self.internal_commands
        [:show, :diff, :model, :create]
      end


      def define(orig_args)
        command, args = get_command(orig_args)
        options = {}
        debug { "Running command #{command} with args #{args.join(',')}" }

        case command
          when :show
            options = defaults_from_optparser(args, [:format])
            run(command, {}, options, args)

          when :diff
            options = defaults_from_optparser(args, [:format])
            run(command, {}, options, args)

          when :model
            options = defaults_from_optparser(args, [:format])
            run(command, {}, options, args)

          when :create
            options = defaults_from_optparser(args)
            run(command, {}, options, args)

          else
            handle_others(orig_args, 'firewall', self.class.internal_commands, command)

        end

      end


      def define1(context)
        super

        @context.desc 'Show firewall definition'
        @context.command :show do |sub|
          sub.action do |global_options, options, args|
            run(sub.name, global_options, options, args)
          end
        end

        @context.desc 'Show differences between model and live definitions'
        @context.command :diff do |sub|
          sub.action do |global_options, options, args|
            run(sub.name, global_options, options, args)
          end
        end

        @context.desc 'Show differences between model and live definitions'
        @context.command :model do |sub|
          sub.action do |global_options, options, args|
            run(sub.name, global_options, options, args)
          end
        end

        @context.desc 'Create the firewall to match the model'
        @context.command :create do |sub|
          sub.action do |global_options, options, args|
            run(sub.name, global_options, options, args)
          end
        end
      end


      def run(action, global_options, options, args)
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
            action  = Rain::Action::Real::UpdateFirewall.new(args)
            results = action.execute(env)
          #output(:model, results)


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
