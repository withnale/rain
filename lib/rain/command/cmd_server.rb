require 'rain/command/cmd_base'

require 'rain/action/model/list_server'
require 'rain/action/real/list_server'
require 'rain/action/real/manage_server'


module Rain

  module Command

    class Server < Base

      acorn_handler [:show, :diff, :model, :create, :action, :poweron, :poweroff, :delete] => :acorn_default_handler


      def acorn_default_handler(orig_args)
        command, args = get_command(orig_args)
        options = {}
        debug { "Running command '#{command}' with args #{args.join(',')}" }

        case command
          when :show
            options = defaults_from_optparser(args, [:format, :servers])
            run(command, {}, options, args)

          when :diff
            options = defaults_from_optparser(args, [:format])
            run(command, {}, options, args)

          when :model
            options = defaults_from_optparser(args, [:format, :servers, :template, :confirmcode])
            run(command, {}, options, args)

          when :action
            options = defaults_from_optparser(args, [:format, :servers, :confirmcode]) do |opts, options|
              action_options = [:create, :delete, :poweroff, :poweron, :show]
              # TODO - Validation of --action broken
              # opts.on("-A", "--action [LIST]", action_options, Array, "List of actions (#{action_options.join(',')})") do |v|
              options[:action] = []
              opts.on("-A", "--action [LIST]", Array, "List of actions (#{action_options.join(',')})") do |v|
                options[:action] = v
              end
            end
            run(command, {}, options, args)

          when :create, :delete, :poweron, :poweroff
            options = defaults_from_optparser(args, [:format, :servers, :confirmcode])
            run(command, {}, options, args)

          else
            handle_others(orig_args, 'server', self.class.internal_commands, command)
        end

      end


      def run(action_verb, global_options, options, args)
        @options = options
        case action_verb
          when :show
            zone = get_object_from_param(args.first, :zone, [:zone, :env])
            action = Rain::Action::Real::ListServer.new(zone)
            results = action.execute(zone)
            output(:show, results)

          when :diff
            env = get_object_from_param(args.first, :env, [:env])
            action = Rain::Action::Model::ListServer.new(args)
            model_results = action.execute(env)

            zone = get_object_from_param(args.first, :zone, [:zone, :env])
            action = Rain::Action::Real::ListServer.new(zone)
            live_results = action.execute(zone)

            generate_diff do |model_handle, live_handle|
              output(:model, model_results, model_handle)
              output(:show, live_results, live_handle)
            end

          when :model
            env = get_object_from_param(args.first, :env, [:env])
            action = Rain::Action::Model::ListServer.new(args)
            results = action.execute(env)
            if @options[:template]
              output_to_erb(results, env)
            else
              output(:model, results)
            end

          when :create
            env = get_object_from_param(args.first, :env, [:env])
            env.zone.zone_check(@options)
            action = Rain::Action::Real::ManageServer.new(args, options)
            results = action.create(env)

          when :delete, :poweron, :poweroff
            env = get_object_from_param(args.first, :env, [:env])
            env.zone.zone_check(@options)
            action = Rain::Action::Real::ManageServer.new(args, options)
            results = action.execute(action_verb, env)

          when :action
            options[:action] ||= []
            options[:action].each do |actionstring|
              action = actionstring.to_sym
              next if action == :action
              puts "Performing action #{action}"
              run(action, global_options, options, args)
            end

          else
            puts "Unknown option #{action}"
        end
      end


      def output_metadata(command, results)
        pp results


      end


      def output_to_erb(results, env)

        # Check if template exists
        template_list = Rain::Config.findpath('$.config.templates')

        template = template_list[@options[:template]]
        unless template
          raise Rain::Errors::TemplateNotDefined, :template_name => @options[:template]
        end
        template_path = File.expand_path(template, Rain::Config.basedir)
        unless File.exists?(template_path)
          raise Rain::Errors::TemplateNotFound, :template_name => @options[:template],
                                                :template_path => template_path
        end
        require 'erb'
        erb = ERB.new(File.read(template), 0, '<>')

        puts erb.result(binding)

      end



      def output(command, results, handle = $stdout)
        diff_output = (handle != $stdout)

        format = @options[:format].new(handle)

        format.column :name, {:width => 30}
        format.column :status, {:width => 20} if diff_output == false && command == :show
        format.column :role, {:width => 20}
        format.column :mem, {:width => 6}
        format.column :cpu, {:width => 3}
        format.column :network, {:width => 15}
        format.column :address

        format.header(false) unless @options[:noheader]

        results.sort.each do |server_name, row|
          status = row[:status]
          case command
            when :show
              item = [
                  {:column => :name, :value => server_name},
                  {:column => :status, :value => row[:status]},
                  {:column => :role, :value => 'role'},
                  {:column => :mem, :value => row[:memory]},
                  {:column => :cpu, :value => row[:cpu]},
                  {:column => :network, :value => row[:network]},
                  {:column => :address, :value => row[:address]},
              ]
            when :model
              # TODO - fix this hack when corrected formatted output
              role = diff_output ? 'role' : row[:vm][:metadata][:role]
              item = [
                  {:column => :name, :value => server_name},
                  {:column => :role, :value => role},
                  {:column => :mem, :value => row[:vm][:hardware_config][:memory]},
                  {:column => :cpu, :value => row[:vm][:hardware_config][:cpu]},
                  {:column => :network, :value => row[:vm][:network_connections].first[:name]},
                  {:column => :address, :value => row[:vm][:network_connections].first[:ip_address]},
              ]
          end
          format.row(item)
        end
        format.complete
      end

    end # class Server

  end
end

