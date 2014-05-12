require 'rain/action/base'
require 'rain/object/zone'
require 'rain/errors'

module Rain
  module Action
    module Model

      class ListNat < Rain::Action::Base


        def execute(env)
          model = env.model
          nat = model.get(:nat)
          nat.data(env)
        end

      end


    end
  end
end