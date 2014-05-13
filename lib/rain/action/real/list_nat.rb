require 'rain/action/base'
require 'rain/object/zone'
require 'rain/errors'
require 'rain/providers/vcloud/helper'


module Rain
  module Action
    module Real

      class ListNat < Rain::Action::Base

        def execute(zone)
          nat = zone.get(:nat)
          nat.show
        end

      end

    end
  end
end