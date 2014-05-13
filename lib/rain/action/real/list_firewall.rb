require 'rain/action/base'
require 'rain/object/zone'
require 'rain/errors'
require 'rain/providers/vcloud/helper'


module Rain
  module Action
    module Real

      class ListFirewall < Rain::Action::Base

        def execute(zone)
          firewall = zone.get(:firewall)
          firewall.show
        end

      end

    end
  end
end