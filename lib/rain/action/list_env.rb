require 'rain/action/base'
require 'rain/object/env'

module Rain
    module Action

    class ListEnv < Base


      def execute(param = nil)
        envs = Rain::Object::Env.findAll
      end

    end


  end
end