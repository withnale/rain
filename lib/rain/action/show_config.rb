require 'rain/action/base'

module Rain
    module Action

    class ShowConfig < Base


      def execute(param = nil)
        Rain::Config.config
      end

    end


  end
end