require 'rain/action/base'
require 'rain/object/zone'
require 'rain/errors'
require 'rain/providers/vcloud/helper'


module Rain
  module Action
    module Model

      class ListServer < Rain::Action::Base


        def execute(env)
          model = env.model
          servers = model.get(:server)
          servers.data(env)
        end

      end


    end
  end
end
