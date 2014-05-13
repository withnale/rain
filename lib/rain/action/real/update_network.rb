require 'rain/action/base'
require 'rain/object/zone'
require 'rain/errors'
require 'rain/providers/vcloud/helper'


module Rain
  module Action
    module Real

      class UpdateNetwork < Rain::Action::Base

        def execute(env)
          zone = env.zone
          network = zone.get(:network)

          model = env.model
          network_model = model.get(:network)
          data = network_model.data(env)

          network.update(data)

        end

      end

    end
  end
end
