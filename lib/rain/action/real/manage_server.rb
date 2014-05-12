require 'rain/action/base'
require 'rain/object/zone'
require 'rain/errors'
require 'rain/providers/vcloud/helper'


module Rain
  module Action
    module Real

      class ManageServer < Rain::Action::Base

        def get_servers(server_model)
          server_list = @options[:servers]
          unless server_list
            server_list = server_model.keys
          end
          server_list
        end

        def execute(action, env)
          zone = env.zone
          server = zone.get(:server)

          model = env.model
          server_model = model.get(:server)
          model_data = server_model.data(env)

          serverlist = get_servers(model_data)

          debug { "Got serverlist #{serverlist.inspect}" }
          serverlist.each do |server_name|
            begin
              #puts server_name
              server.do_action(action, env, model_data, server_name)
            rescue Rain::Errors::NoSuchServer => e
              e.print_message
            end
          end

        end


        def create(env)
          zone = env.zone
          server = zone.get(:server)

          model = env.model
          server_model = model.get(:server)
          model_data = server_model.data(env)

          serverlist = get_servers(model_data)
          serverlist.each do |server_name|
            begin
              server.create(env, model_data, server_name)
            rescue Rain::Errors::NoSuchServer => e
              e.print_message
            end
          end

        end


      end

    end
  end
end
