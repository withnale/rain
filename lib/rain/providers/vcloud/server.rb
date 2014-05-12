require 'rain/providers/vcloud/base'

require 'pp'

module Rain
  module Providers
    module VCloud
      class Server < Base

        include Rain::Util::Logger

        def create(env, vapp_config, server_name)
          server_config = vapp_config[server_name]
          if server_config.nil?
            raise Rain::Errors::NoSuchServer
          end
          foginterface = Vcloud::FogInterface.new(handle)

          # Allow the settings for catalog and template to be overridden and to also have defaults
          server_config[:catalog] =
            env.zone.config['catalog'] || server_config[:catalog] || env.zone.config['default_catalog']
          server_config[:catalog_item] =
            env.zone.config['template'] || server_config[:catalog_item] || env.zone.config['template']
          server_config[:vdc_name]     ||= @vdc.name

          provisioner = Vcloud::Vapp.new(foginterface)
          provisioner.provision(server_config)
        end



        def do_action(action, env, vapp_config, server_name)

          server_config = vapp_config[server_name]
          unless server_config
            puts "warn: Server #{server_name} does not exist in model"
          end
          foginterface = Vcloud::FogInterface.new(handle)
          model_vapp = foginterface.get_vapp_by_vdc_and_name(@vdc, server_name)

          unless model_vapp
            raise Rain::Errors::NoSuchServer, :server_name => server_name, :env => env.name
          end
          puts "Performing #{action} on #{server_name}"
          case action
            when :delete
              result = foginterface.delete_vapp(model_vapp.id)
            when :poweron
              result = foginterface.power_on_vapp(model_vapp.id)
            when :poweroff
              vapp = @vdc.vapps.get_by_name(server_name)
              result = vapp.undeploy
              #result = foginterface.power_off_vapp(model_vapp.id)
            else
              raise StandardError
          end

        end



        def data(list = nil)
          return @data if @data

          connect

          @data  = {}
          vapps = @vdc.vapps
          vapps.each do |vapp|

            #puts "\n\n"
            #puts vapp.name

            #data[vapp.name][:vapp] = vapp
            other_vapp      = handle.get_vapp(vapp.id)

            debug { "GET_VAPP" }
            debug { other_vapp.to_yaml }

            # TODO Assumption: This only checks for one VM
            # TODO Add metadata collection
            debug { "\n\nVAPP.VMS" }
            vm = vapp.vms.first
            next unless vm
            debug { vm.to_yaml }
            jsonpath = Rain::Util::JsonPath.new(other_vapp)
            @data[vapp.name] = {
                :role    => 'unknown',
                :status  => vm.attributes[:status],
                :cpu     => vm.attributes[:cpu],
                :memory  => vm.attributes[:memory],
                :network => vapp.network_config.first[:networkName],
                :address => vm.attributes[:ip_address],
                :image   => 'none',
                :data    => other_vapp,
            }
          end
          @data
        end


        def show(list = nil)
          data(list)
        end

        end
    end
  end
end
