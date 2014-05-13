require 'rain/action/base'
require 'rain/object/zone'
require 'rain/errors'
require 'rain/providers/vcloud/helper'


module Rain
  module Action
    module Real

      class UpdateFirewall < Rain::Action::Base

        def execute(env)
          # Get the firewall provider object
          zone = env.zone
          firewall = zone.get(:firewall)

          # Get the model definition
          model = env.model
          firewall_model =  model.get(:firewall)
          data = firewall_model.data(env)

          # Update the firewall
          firewall.update(data)
        end

      end

    end
  end
end