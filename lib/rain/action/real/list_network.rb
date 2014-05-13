require 'rain/action/base'
require 'rain/object/zone'
require 'rain/errors'
require 'rain/providers/vcloud/helper'


module Rain
  module Action
    module Real

      class ListNetwork < Rain::Action::Base

        def execute(zone)
          network = zone.get(:network)
          network.show
        end

      end

    end
  end
end