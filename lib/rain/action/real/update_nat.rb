require 'rain/action/base'
require 'rain/object/zone'
require 'rain/errors'
require 'rain/providers/vcloud/helper'


module Rain
  module Action
    module Real

      class UpdateNat < Rain::Action::Base

        def execute(env)
          # Get the NAT provider object
          zone = env.zone
          nat = zone.get(:nat)

          # Get the model definition
          model = env.model
          nat_model =  model.get(:nat)
          data = nat_model.data(env)

          # Update the NAT rules
          nat.update(data)
        end

      end

    end
  end
end