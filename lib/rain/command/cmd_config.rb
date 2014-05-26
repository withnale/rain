require 'rain/command/cmd_base'
require 'rain/action/show_config'
require 'awesome_print'

module Rain

  module Command

    class Config < Base

      acorn_handler [:show] => :acorn_default_handler


      def acorn_default_handler(orig_args)
        command, args = get_command(orig_args)
        options = {}
        debug { "Running command #{command} with args #{args.join(',')}" }

        case command
          when :show
            options = defaults_from_optparser(args, [:format])
            action = Rain::Action::ShowConfig.new(args)
            results = action.execute
            output(:show, results)

          else
            handle_others(orig_args, 'config', self.class.internal_commands, command)
        end

      end


      def output(command, results)
        ap results
      end


    end

  end


end
