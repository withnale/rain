require 'rain/command/cmd_base'
require 'rain/action/list_zone'

module Rain
  module Command
    class Zone < Base

      def self.internal_commands
        [:list]
      end

      def define(orig_args)
        command, args = get_command(orig_args)
        options = {}
        debug { "Running command #{command} with args #{args.join(',')}" }

        case command
          when :list
            options = defaults_from_optparser(args, [:format])
            action  = Rain::Action::ListZone.new(args)
            results = action.execute
            output(:list, results, options)
          else
            handle_others(orig_args, 'zone', self.class.internal_commands, command)
        end
      end


      def output(command, results, options)

        format = options[:format].new

        format.column :name, {:width => 30}
        format.column :type, {:width => 6}   if options[:long]
        format.column :default_env, {:desc => 'default-env', :width => 20} if options[:long]
        format.column :provider

        format.header(false) unless options[:noheader]

        results.sort.each do |zone_name, row|

          item = [
              { :column => :name, :value => zone_name },
              { :column => :type, :value => 'simple' },
              { :column => :default_env, :value => 'unknown' },
              { :column => :provider, :value => row.config['vdc'] },
          ]

          format.row(item)
        end

        format.complete

      end

    end
  end
end
