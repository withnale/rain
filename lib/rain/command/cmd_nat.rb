require 'rain/command/cmd_base'

require 'rain/action/model/list_nat'
require 'rain/action/real/list_nat'
require 'rain/action/real/update_nat'

module Rain

  module Command

    class Nat < Base

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
            handle_others(orig_args, 'nat', self.class.internal_commands, command)
        end
        0
      end



      def run(action, global_options, options, args)
        @options = options
        case action
          when :show
            zone    = get_object_from_param(args.first, :zone, [:zone, :env])
            action  = Rain::Action::Real::ListNat.new(args)
            results = action.execute(zone)
            output(:show, results[:NatRule])

          when :diff
            env           = get_object_from_param(args.first, :env, [:env])
            action        = Rain::Action::Model::ListNat.new(args)
            model_results = action.execute(env)

            zone         = get_object_from_param(args.first, :zone, [:env])
            action       = Rain::Action::Real::ListNat.new(args)
            live_results = action.execute(zone)

            generate_diff do |model_handle, live_handle|
              output(:model, model_results[:NatService][:NatRule], model_handle)
              output(:show, live_results[:NatRule], live_handle)
            end

          when :model
            env     = get_object_from_param(args.first, :env, [:model, :env])
            action  = Rain::Action::Model::ListNat.new(args)
            results = action.execute(env)
            output(:model, results[:NatService][:NatRule])

          when :create
            env     = get_object_from_param(args.first, :env, [:env])
            env.zone.zone_check(@options)
            action  = Rain::Action::Real::UpdateNat.new(args)
            results = action.execute(env)

        end

      end


      def output(command, results, handle = $stdout)
        handle.puts "%-6s %-6s %-20s %-6s   %-20s %-6s" %
                        ['type', 'proto', 'origin', 'port', 'dest', 'port']

        results.each do |row|
          handle.puts "%-6s %-6s %-20s %-6s   %-20s %-6s" %
                          [row[:RuleType], row[:GatewayNatRule][:Protocol] || 'Any',
                           row[:GatewayNatRule][:OriginalIp], row[:GatewayNatRule][:OriginalPort] || 'Any',
                           row[:GatewayNatRule][:TranslatedIp], row[:GatewayNatRule][:TranslatedPort] || 'Any']
        end
      end


    end

  end


end
