require 'rain/action/base'
require 'rain/object/zone'
require 'rain/errors'
require 'rain/providers/vcloud/helper'


module Rain
  module Action
    module Real

      class ListServer < Rain::Action::Base

        def execute(zone)
          server = zone.get(:server)
          server.show
        end

      end

    end
  end
end
