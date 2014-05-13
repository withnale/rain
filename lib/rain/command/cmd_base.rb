require 'tempfile'
require 'rainbow'
require 'optparse'

module Rain
  module Command
    class Base

      include Rain::Util::Logger
      attr_accessor :args

      def command
        @command ||= @args.empty? ? nil : @args.shift.to_sym
      end

      def self.internal_commands
        []
      end

      def self.children
        @children
      end

      def initialize(config = {})
        @config = config
        @command_path = []
      end

      def self.set_path(list, arg)
        @path = list
        @path << arg
      end

      def self.path
        @path || []
      end

      def self.inherited(subclass)
        @children ||= {}
        string = subclass.to_s.match(/(\w+)$/).to_s.downcase.to_sym
        subclass.set_path(self.path, string)
        @children[string] = subclass
        #debug { "New subclass #{self} #{subclass} #{@children.keys.join(',')}" }
      end

      def self.global_options(opts, options = nil)

        opts.separator ''

        opts.on("-d", "--debug", "Enable Debugging") do |v|
          Rain::Config.set_global_option(:debug, true)
          Rain::Util::RainLogger.setup({:debug => true})
        end
        opts.on("-h", "--help", "Show Help") do |v|
          if options
            raise Rain::Errors::ErrorHelpText,  :helptext => opts
          end
        end
      end

      def get_command(args)
        command, *rem = *args
        unless command
          return nil, []
        end
        @command_path = self.class.path + [ command ]
        return command.to_sym, rem
      end


      def handle_others(args1, prefix, commands, command = nil)

        begin
          parser = get_valid_options(prefix, commands, {})
          parser.parse(args1)

        end
        raise Rain::Errors::InvalidCommand, :command => command, :help => parser if command
        raise Rain::Errors::ErrorHelpText, :helptext =>parser
      end

      def self.run(args)
        options = {}
        parser = OptionParser.new do |opts|
          global_options(opts)
        end
        #puts "args = #{args.inspect}"
        tmp1 = parser.order(args)
        #puts "tmp = #{tmp1.inspect}"
        prefix = args.first(args.size - tmp1.size)

        #puts "prefix = #{prefix.inspect}"
        newargs = tmp1 + prefix
        #puts "newargs = #{newargs.inspect}"
        begin
          parse(newargs)
        rescue Rain::Errors::ErrorHelpText => e
          puts e.args[:helptext]
        end
      end

      def self.parse(args)
        unless @children
          instance = self.new
          instance.args = args
          instance.define(args)
          return
        end
        if @children && args.count > 0 && @children[args.first.to_sym]
            # Pass control to the underlying class
            klass = @children[args.first.to_sym]
            args.shift
            klass.parse(args)
        else
          instance = self.new
          instance.args = args
          instance.define(args)
        end
      end


      def define(args)
        debug { " cmd_base:define args=[#{args.join(',')}]" }
        command_path = self.class.path.map{|x| x.to_s}.join('.')
        list = self.class.children ? self.class.children.keys : self.class.internal_commands
        #parser =  get_valid_options(command_path, list)
        handle_others(args, command_path, list)
        #parser.parse!
        #raise Rain::Errors::ErrorHelpText, :helptext => text
      end

      def get_valid_options(prefix, commands, options = nil)
        self.class.get_valid_options_internal(prefix, commands, options)
      end

      def self.get_valid_options(prefix, commands, options = nil)
        self.get_valid_options_internal(prefix, commands, options)
      end


      def self.get_valid_options_internal(prefix, commands, options)

        # We need to skip this if we are at the base
        str = prefix ? "#{prefix.to_s}." : ''

        parser = OptionParser.new do |opts|
          opts.banner = "Usage: rain #{prefix} [options]"

          opts.separator ''
          opts.separator I18n.t("rain.desc.command.#{str}_desc", {}).lines.map { |x| "  #{x}" }
          opts.separator ''
          opts.separator ''

          opts.separator 'Available subcommands:'
          opts.separator ''

          commands.each do |command|
            opts.separator "  #{command.to_s} - "
            shortdesc = I18n.t("rain.desc.command.#{str}#{command.to_s}._desc", {}).lines.first
            opts.separator "      #{shortdesc}"
          end
          opts.separator ''
          global_options(opts, options)
        end

        parser
      end


      def defaults_from_optparser(args, list = [])
        options = {}


        parser = OptionParser.new do |opts|
          opts.banner = "Usage: rain #{@command_path.join(' ')} [options]"

          unless @command_path.empty?
            ui_prefix = @command_path.join('.')
            opts.separator ''
            opts.separator I18n.t("rain.desc.command.#{ui_prefix}._desc", {}).lines.map { |x| "  #{x}" }
            opts.separator ''
            opts.separator 'Available options:'
          end

          list.each do |param|
            case param
              when :servers
                opts.on("-s", "--servers SERVERS", Array, "List of Servers") do |v|
                  options[:servers] ||= []
                  options[:servers] += v
                end

              when :all_envs
                opts.on("--all-envs", "Select all environments") do |v|
                  options[:all_envs] = v
                end

              when :all_zones
                opts.on("--all-zones", "Select all zones") do |v|
                  options[:all_zones] = v
                end

              when :long
                opts.on("--long", "Long Format") do |v|
                  options[:long] = v
                end

              when :show_label
                opts.on("--show-label", 'Show label in tabular output') do |v|
                  options[:show_label] = v
                end

              when :format
                options[:format] = Rain::Util::Format::Table
                opts.on("-f", "--format NAME", Rain::Util::Format::FORMATTERS,
                        "Output format (#{Rain::Util::Format::FORMATTERS.keys.join(',')})") do |f|
                  options[:format] = f
                end

              when :template
                opts.on("-t", "--template NAME", "Output Template Name") do |f|
                  options[:template] = f
                end

            end

            yield opts, options if block_given?
          end

          self.class.global_options(opts, options)

        end

        begin
          parser.parse!(args)
          if options[:help]
            puts parser
            raise Rain::Errors::ErrorHelpText, :helptext => parser.to_s
          end
        rescue OptionParser::InvalidArgument => e
          raise Rain::Errors::ErrorHelpText, :error => e.to_s, :helptext => parser
        rescue OptionParser::InvalidOption => e
          raise Rain::Errors::ErrorHelpText, :error => e.to_s, :helptext => parser
        end
        options
      end

      def defaults(cmd, list)
        list.each do |param|
          case param
            when :servers
              cmd.flag [:s, :servers],
                       :desc => "List of Servers", :type => Array
            when :format
              cmd.flag [:format],
                       :desc => "Output format (#{Rain::Util::Format::FORMATTERS.keys.join(',')})",
                       :must_match => Rain::Util::Format::FORMATTERS,
                       :default_value => Rain::Util::Format::Table.new
            when :long
              cmd.switch [:long],
                         :desc => 'Long Format'
            when :all_envs
              cmd.switch [:all_envs],
                         :desc => 'Select all environments'
            when :all_zones
              cmd.switch [:all_zones],
                         :desc => 'Select all zones'
            when :show_label
              cmd.switch [:show_label],
                         :desc => 'Show label in tabular output'

          end
        end
      end


      def generate_diff

        begin
          model_handle = Tempfile.new("model")
          live_handle = Tempfile.new("live")

          yield model_handle, live_handle

          model_handle.close
          live_handle.close

          diffcmd = ENV["DIFF"] || '/usr/bin/diff'
          diffopts = "--new-line-format='L %L' --old-line-format='M %L' --unchanged-line-format='  %L'"
          output = `#{diffcmd} #{diffopts} #{model_handle.path} #{live_handle.path}`
        ensure
          model_handle.unlink
          live_handle.unlink
        end

        output.lines do |str|
          if str.start_with?('M')
            print str.color(:red)
          elsif str.start_with?('L')
            print str.color(:blue)
          else
            print str
          end
        end

      end

      def get_object_from_type(param, type, output_type)
        case type
          when :env
            return get_type_from_object(Rain::Object::Env.get(param), output_type)
          when :zone
            return get_type_from_object(Rain::Object::Zone.get(param), output_type)
          when :model
            return get_type_from_object(Rain::Object::Model.check(param), output_type)
        end
      end

      def get_type_from_object(object, output_type)
        case object
          when NilClass
            return nil

          when Rain::Object::Env
            case output_type
              when :env
                return object
              when :zone
                return object.zone
              when :model
                return object.model
            end

          when Rain::Object::Zone
            case output_type
              when :zone
                return object
              else
                return nil
            end

          when Rain::Object::Model
            case output_type
              when :model
                return object
              else
                return nil
            end
        end
      end

      def get_object_from_param(param, output_type, order, priority = nil)
        unless param
          raise Rain::Errors::NoParameters, :options => order.join(',')
        end
        if priority
          result = get_object_from_type(param, priority, output_type)
        else
          result = nil
          order.each do |item|

            current = get_object_from_type(param, item, output_type)
            result ||= current
          end
        end
        if result.nil?
          raise Rain::Errors::InvalidParameter, :arg => param, :options => order.join(',')
        end
        result
      end

      def get_objects_from_params(params, output_type, order, options = {}, priority = nil)
        if options[:all_zones]
          list = Rain::Object::Zone.findAll.keys
        elsif options[:all_envs]
          list = Rain::Object::Env.findAll.keys
        else
          list = params
        end
        if list.empty?
          raise Rain::Errors::NoParameters, :options => order.join(',')
        end
        list.map { |x| get_object_from_param(x, output_type, order, priority) }
      end


    end
  end
end
