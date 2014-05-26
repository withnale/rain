require 'rain/command/cmd_base'
require 'rain/action/real/list_image'
require 'rain/action/real/upload_image'

module Rain

  module Command

    class Image < Base

      acorn_handler [:show, :upload] => :acorn_default_handler


      def acorn_default_handler(orig_args)
        command, args = get_command(orig_args)
        options = {}
        debug { "Running command #{command} with args #{args.join(',')}" }

        case command
          when :show
            options = defaults_from_optparser(args, [:format])
            run(command, {}, options, args)

          when :upload
            options = defaults_from_optparser(args) do | opts, options|
              opts.on("-n", "--name NAME", "Name of image to upload") do |v|
                options[:name] = v
              end
            end
            run(command, {}, options, args)
          else
            handle_others(orig_args, 'image', self.class.internal_commands, command)
        end

      end


      def run(action, global_options, options, args)
        case action
          when :show
            zone    = get_object_from_param(args.first, :zone, [:zone, :env])
            action  = Rain::Action::Real::ListImage.new(zone)
            results = action.execute(zone)
            output(:show, results)

          when :upload
            filename = args.shift
            zones = get_objects_from_params(args, :zone, [:zone, :env], options)
            puts "Putting file into zones #{zones.join(',')}"
            action  = Rain::Action::Real::UploadImage.new(zone)
            results = action.execute(filename, zones)

        end
      end



      def output(command, results, handle = $stdout)

        diff_output = (handle != $stdout)

        handle.puts "%-50s %-20s %s" %
                        ['template', 'catalog', 'id' ]

        results.each do |row|
          handle.puts "%-50s %-20s %s" %
                          [row[:name], row[:catalog], row[:id]]
        end

      end


    end

  end


end
