require 'rain/providers/vcloud/base'

module Rain
  module Providers
    module VCloud
      class Firewall < Base

        def show
          data = Rain::Providers::VCloud::Helper.get_firewall(handle, edge_gateway_id)
          data
        end

        def update(config)
          task = handle.post_configure_edge_gateway_services(edge_gateway_id, config)
          handle.process_task(task.body)
        end

      end
    end
  end
end