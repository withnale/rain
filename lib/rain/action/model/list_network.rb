require 'rain/action/base'
require 'rain/object/zone'
require 'rain/errors'
require 'rain/providers/vcloud/helper'


module Rain
  module Action
    module Model

      class ListNetwork < Rain::Action::Base


        def execute(env)
          model = env.model
          network = model.get(:network)
          network.data(env)
        end

      end


    end
  end
end
