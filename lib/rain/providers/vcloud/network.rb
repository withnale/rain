require 'rain/providers/vcloud/base'

module Rain
  module Providers
    module VCloud
      class Network < Base



        def data
          return @data if @data
          @data = Rain::Providers::VCloud::Helper.get_network(handle, edge_gateway_id)
        end

        def show
          data.sort_by {|x| x[:Name] }
        end

        def get_network(name)
          data.select {|x| x[:Name] == name}.first
        end



        def update(data)

          data.each do |network|
            if get_network(network[:name])
              puts "Network already exists #{network[:name]} - skipping"
              next
            end
            puts "Creating network #{network[:name]}"
            xml = network[:data]

            token = handle.vcloud_token
            id = @vdc.id

            Rain::Providers::VCloud::Helper.create_network(@parent.config, id, edge_gateway_id, token, network)
          end

        end

      end
    end
  end
end
