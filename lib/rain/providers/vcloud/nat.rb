require 'rain/providers/vcloud/base'

module Rain
  module Providers
    module VCloud
      class Nat < Base

        def show
          data = Rain::Providers::VCloud::Helper.get_nat(handle, edge_gateway_id)
          data
        end

        def update(config)
          edge_gateway    = Rain::Providers::VCloud::Helper.get_edge_gateway(handle, @vdc)
          name, uri = Rain::Providers::VCloud::Helper.get_edge_gateway_uri(handle, edge_gateway_id)

          # Must add references to the correct interfaces
          config[:NatService][:NatRule].each do |rule|
            rule[:GatewayNatRule][:Interface] = {
                :name => name,
                :href => uri
            }
          end

          task = handle.post_configure_edge_gateway_services(edge_gateway_id, config)
          handle.process_task(task.body)
        end


      end
    end
  end
end