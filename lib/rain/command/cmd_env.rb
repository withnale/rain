require 'rain/command/cmd_base'
require 'rain/action/list_env'

module Rain

  module Command

    class Env < Base

      acorn_handler [:list, :config, :show, :model, :vars, :create] => :acorn_default_handler


      def acorn_default_handler(orig_args)
        command, args = get_command(orig_args)
        options = {}
        debug { "Running command #{command} with args #{args.join(',')}" }

        case command
          when :list
            options = defaults_from_optparser(args, [:format])
            run(command, {}, options, args)

          when :config
            options = defaults_from_optparser(args)
            run(command, {}, options, args)

          when :show
            options = defaults_from_optparser(args, [:format])
            run(command, {}, options, args)

          when :model
            options = defaults_from_optparser(args, [:format])
            run(command, {}, options, args)

          when :vars
            options = defaults_from_optparser(args, [:format])
            run(command, {}, options, args)

          when :create
            options = defaults_from_optparser(args)
            run(command, {}, options, args)

          else
            handle_others(orig_args, 'env', self.class.internal_commands, command)
        end

      end

      def define1(context)
        super

        @context.desc 'List all known environments'
        @context.command :list do |sub|
          defaults(sub, [:format])
          sub.action do |global_options, options, args|
            run(sub.name, global_options, options, args)
          end
        end

        @context.desc 'Show environment config info'
        @context.command :config do |sub|
          sub.action do |global_options, options, args|
            run(sub.name, global_options, options, args)
          end
        end


        @context.desc 'Show specific environment information'
        @context.command :show do |sub|
          defaults sub, [:format]
          sub.action do |global_options, options, args|
            run(sub.name, global_options, options, args)
          end
        end

        @context.desc 'Show the subcomponent models for the environment'
        @context.command :model do |sub|
          defaults sub, [:format]
          sub.action do |global_options, options, args|
            run(sub.name, global_options, options, args)
          end
        end

        @context.desc 'Show variables'
        @context.command :vars do |sub|
          sub.action do |global_options, options, args|
            run(sub.name, global_options, options, args)
          end
        end

        @context.desc 'Create an environment'
        @context.command :create do |sub|
          sub.action do |global_options, options, args|
            run(sub.name, global_options, options, args)
          end
        end

      end


      def run(action, global_options, options, args)
        case action
          when :list
            action = Rain::Action::ListEnv.new(args)
            debug { __FILE__ }
            results = action.execute
            output_format(:list, results, options)

          when :model
            puts "\nShowing Network model for #{args.first}".color(:red)
            Rain::Command::Network.new.run(:model, global_options, options, args)
            puts "\nShowing Server model for #{args.first}".color(:red)
            Rain::Command::Server.new.run(:model, global_options, options, args)
            puts "\nShowing Firewall model for #{args.first}".color(:red)
            Rain::Command::Firewall.new.run(:model, global_options, options, args)
            puts "\nShowing NAT model for #{args.first}".color(:red)
            Rain::Command::Nat.new.run(:model, global_options, options, args)

          when :show
            puts "\nShowing Network for #{args.first}".color(:red)
            Rain::Command::Network.new.run(:show, global_options, options, args)
            puts "\nShowing Server for #{args.first}".color(:red)
            Rain::Command::Server.new.run(:show, global_options, options, args)
            puts "\nShowing Firewall for #{args.first}".color(:red)
            Rain::Command::Firewall.new.run(:show, global_options, options, args)
            puts "\nShowing NAT for #{args.first}".color(:red)
            Rain::Command::Nat.new.run(:show, global_options, options, args)

          when :create
            puts "\nCreating Network for #{args.first}".color(:red)
            Rain::Command::Network.new.run(:create, global_options, options, args)
            puts "\nCreating Server for #{args.first}".color(:red)
            Rain::Command::Server.new.run(:create, global_options, options, args)
            puts "\nPoweron Server for #{args.first}".color(:red)
            Rain::Command::Server.new.run(:poweron, global_options, options, args)
            puts "\nCreating Firewall for #{args.first}".color(:red)
            Rain::Command::Firewall.new.run(:create, global_options, options, args)
            puts "\nCreating NAT for #{args.first}".color(:red)
            Rain::Command::Nat.new.run(:create, global_options, options, args)

          when :config
            env = get_object_from_param(args.first, :env, [:zone, :env])
            output_config(env)

          when :vars
            action = Rain::Action::ListEnv.new(args)
            debug { __FILE__ }
            results = action.execute
            outputvars(results)

        end
      end

      def outputvars(results)
        variables = results.map { |k, v| v.variables.keys }.flatten.uniq
        columns   = variables.reject { |x| %w|envname zonename modelname|.include?(x.to_s) }.sort
        varoutput = columns.map { |x| "%-20s" % x.to_s }.join('')
        printf "%-20s %s\n" % ['', varoutput]

        results.each do |envname, env|
          varoutput = columns.map { |x| "%-20s" % [env.variables[x]] }.join('')
          printf "%-20s %s\n" % [envname, varoutput]
        end
      end

      def output(command, results)

        case command
          when :list
            puts "%-30s %-6s %-20s %s" %
                     ['environment', 'type', 'model', 'zone']
        end

        results.each do |env_name, row|
          case command
            when :list
              puts "%-30s %-6s %-20s %s" %
                       [env_name, row.type, row.model, row.zone]
          end
        end

      end

      def define_formatter
        @options[:format] = Rain::Util::Format::Table.new
        opts.on('-f', '--format NAME', Emo::Util::Format::FORMATTERS,
                'Output format (pretty, csv, table)') do |f|
          @options[:format] = f
        end

      end

      def output_format(command, results, options)

        return unless results

        format = options[:format].new
        format.column :environment, { :width => results.keys }
        format.column :type, { :width => 10 }
        format.column :model, { :width => results.map { |k, v| v.model.to_s } }
        format.column :zone

        format.header(false) unless options[:noheader]

        keys = results.keys
        case options[:sortby]
          when :date
            keys.sort_by! { |x| results[x][:timestamp] }
          when :alpha
            keys.sort!
        end

        list = []
        keys.each do |name|

          item = [
              { :column => :environment, :value => name },
              { :column => :type, :value => results[name].type },
              { :column => :model, :value => results[name].model },
              { :column => :zone, :value => results[name].zone },
          ]

          list << item
        end

        list.each { |x| format.row(x) }
        format.complete

      end

      def output_config(env)
        puts <<"EOT"
Environment: #{env.name}
Model:       #{env.model}
Zone:        #{env.zone}
EOT
        puts "\nZone"
        env.zone.config.reject { |x| x['password'] }.each do |k, v|
          puts '  %-18s %s' % ["#{k}:", v]
        end
        puts "\nVariables"
        env.variables.each do |k, v|
          puts '  %-18s %s' % ["#{k}:", v]
        end
        puts
      end


    end

  end


end
