module Rain
  module Util
    module Acorn

      def self.included base
        base.send :include, InstanceMethods
        base.extend ClassMethods
      end


      #
      # ClassMethods for Mixin
      #
      module ClassMethods

        def acorn_command_set_path(list, arg)
          @acorn_command_path = list
          @acorn_command_path << arg
        end

        def acorn_command_path
          @acorn_command_path || []
        end



        def internal_commands
          acorn_instance_command.keys
        end

        def acorn_handler(*args)
          args.each do |arg|
            arg.each do |commands, method|
              commands.each do |command|
                @acorn_instance_command_map ||= {}
                @acorn_instance_command_map[command] = method
              end
            end
          end
        end

        def acorn_instance_command
          @acorn_instance_command_map ||= {}
        end

        def acorn_get_child(command)
          @acorn_children ||= {}
          @acorn_children[command]
        end

        def inherited(subclass)
          @acorn_children ||= {}
          string = subclass.to_s.match(/(\w+)$/).to_s.downcase.to_sym
          subclass.acorn_command_set_path(self.acorn_command_path, string)
          @acorn_children[string] = subclass
          #debug { "New subclass #{self} #{subclass} #{@children.keys.join(',')}" }
        end

        def acorn_call_command_method(method, args)
          instance = self.new
          instance.args = args
          instance.method(method).call(args)
        end

        def acorn_parse(args)
          return acorn_call_command_method(:acorn_default_handler, args) if args.count == 0

          current_command = args.first.to_sym


          if command_method = acorn_instance_command[current_command]
            # 1. if there is an internal map entry pass control to the method
            acorn_call_command_method(command_method, args)
          elsif klass = acorn_get_child(current_command)
            # 2. If command is found in the subclasses then pass to the subclass
            args.shift
            klass.acorn_parse(args)
          else
            return acorn_call_command_method(:acorn_default_handler, args)
          end
        end



      end


      #
      # InstanceMethods for Mixin
      #
      module InstanceMethods

        def acorn_default_handler(args)
          debug { " cmd_base:define args=[#{args.join(',')}]" }
          command_path = self.class.acorn_command_path.map{|x| x.to_s}.join('.')
          list = self.class.children ? self.class.children.keys : self.class.acorn_instance_command.keys
          #parser =  get_valid_options(command_path, list)
          handle_others(args, command_path, list)
          #parser.parse!
          #raise Rain::Errors::ErrorHelpText, :helptext => text
        end


        def get_command(args)
          command, *rem = *args
          unless command
            return nil, []
          end
          @command_path = self.class.acorn_command_path + [ command ]
          return command.to_sym, rem
        end


      end


    end
  end
end