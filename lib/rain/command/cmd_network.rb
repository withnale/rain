require 'rain/command/cmd_base'
require 'rain/action/model/list_network'
require 'rain/action/real/list_network'
require 'rain/action/real/update_network'

require 'ipaddr'

module Rain

  module Command

    class Network < Base

      acorn_handler [:show, :diff, :model, :create] => :acorn_default_handler


      def acorn_default_handler(orig_args)
        command, args = get_command(orig_args)
        options = {}
        debug { "Running command #{command} with args #{args.join(',')}" }

        case command
          when :show
            options = defaults_from_optparser(args, [:all_envs, :all_zones, :show_label, :format]) do |opts, options|
              opts.on("--only-upstream", 'Only show entries with upstreams') do |v|
                options[:action] = v
              end
            end
            run(command, {}, options, args)

          when :diff
            options = defaults_from_optparser(args, [:format])
            run(command, {}, options, args)

          when :model
            options = defaults_from_optparser(args, [:all_envs, :show_label, :format])
            run(command, {}, options, args)

          when :create
            options = defaults_from_optparser(args, [:confirmcode])
            run(command, {}, options, args)

          else
            handle_others(orig_args, 'network', self.class.internal_commands, command)
        end

      end



      def run(action, global_options, options, args)
        @options = options

        case action
          when :show
            zones = get_objects_from_params(args, :zone, [:zone, :env], options)
            zones.each do |zone|
              action  = Rain::Action::Real::ListNetwork.new(zone)
              results = action.execute(zone)
              puts "Showing live data for zone #{zone.name}" #if zones.count > 1
              output(:show, results, zone.name)
              #puts
            end

          when :diff
            env           = get_object_from_param(args.first, :env, [:env])
            action        = Rain::Action::Model::ListNetwork.new(env)
            model_results = action.execute(env)

            zone         = get_object_from_param(args.first, :zone, [:zone, :env])
            action       = Rain::Action::Real::ListNetwork.new(zone)
            live_results = action.execute(zone)

            generate_diff do |model_handle, live_handle|
              output(:model, model_results, '', model_handle)
              output(:show, live_results, '', live_handle)
            end

          when :model
            envs = get_objects_from_params(args, :env, [:env], options)

            envs.each do |env|
              action  = Rain::Action::Model::ListNetwork.new(env)
              results = action.execute(env)
              puts "Showing model for environment #{env.name}" if envs.count > 1
              output(:model, results, env.name, '')
              puts
            end

          when :create
            env     = get_object_from_param(args.first, :env, [:model, :env])
            env.zone.zone_check(@options)
            action  = Rain::Action::Real::UpdateNetwork.new(args)
            results = action.execute(env)

        end
      end


      def netmask_to_cidr(arg)
        IPAddr.new(arg).to_i.to_s(2).count('1')
      end


      def subnets_to_array(object)
        case object
          when Array
            return object
          when Hash
            return [object]
          else
            return []
        end
      end

      # How bad is this data structured in the API??
      def subnetRange(subnethash)

        return '', '' unless subnethash[:IpRanges]
        range = subnethash[:IpRanges]

        return '','' unless range.class == Hash
        start  = range[:IpRange][:StartAddress]
        finish = range[:IpRange][:EndAddress]
        return 1, start if start == finish
        startmatch  = start.match(/\b(?<prefix>\d{1,3}\.\d{1,3}\.\d{1,3}\.)(?<suffix>\d{1,3})\b/)
        finishmatch = finish.match(/\b(?<prefix>\d{1,3}\.\d{1,3}\.\d{1,3}\.)(?<suffix>\d{1,3})\b/)

        count = finishmatch[:suffix].to_i - startmatch[:suffix].to_i + 1
        return count, "#{start}-#{finishmatch[:suffix]}" if startmatch[:prefix] == finishmatch[:prefix]
      end


      def output(command, results, label, handle = $stdout)

        diff_output = (handle != $stdout)

        format = @options[:format].new(handle)

        format.column :label, { :width => 20 } if @options[:show_label]
        format.column :network, { :width => 20 }
        format.column :displayname, { :width => 20 }
        format.column :type, { :width => 12 }
        format.column :address, { :width => 20 }
        format.column :gateway, { :width => 20 }
        format.column :no, { :width => 2 }
        format.column :range

        format.header(false) unless @options[:noheader]

        results.each do |row|
          item = []
          case command
            when :show
              next if diff_output && row[:InterfaceType] != 'internal'
              subnets = subnets_to_array(row[:SubnetParticipation])
              subnets.each do |subnet|
                count, ipranges = subnetRange(subnet)
                next if @options[:only_upstream] && count == 0
                address = "#{subnet[:IpAddress]}/#{netmask_to_cidr(subnet[:Netmask])}"

                format.row([
                               { :column => :label, :value => label },
                               { :column => :network, :value => row[:Name] },
                               { :column => :displayname, :value => row[:DisplayName] },
                               { :column => :type, :value => row[:InterfaceType] },
                               { :column => :address, :value => address },
                               { :column => :gateway, :value => subnet[:Gateway] },
                               { :column => :no, :value => count },
                               { :column => :range, :value => ipranges },
                           ])

              end
            when :model
              address = "#{row[:gateway]}/#{netmask_to_cidr(row[:netmask])}"

              format.row([
                             { :column => :label, :value => label },
                             { :column => :network, :value => row[:name] },
                             { :column => :displayname, :value => row[:name] },
                             { :column => :type, :value => 'internal' },
                             { :column => :address, :value => address },
                             { :column => :gateway, :value => row[:gateway] },
                             { :column => :no, :value => '' },
                             { :column => :range, :value => '' },
                         ])

          end
        end
        format.complete

      end


    end

  end


end
