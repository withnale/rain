require 'rain/action/base'
require 'rain/object/zone'
require 'rain/errors'
require 'rain/providers/vcloud/helper'


module Rain
  module Action
    module Model

      class ListFirewall < Rain::Action::Base


        def execute(env)
          model = env.model
          firewall =  model.get(:firewall)
          firewall.data(env)
        end

      end


    end
  end
end
