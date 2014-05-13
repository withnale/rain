require 'rain/action/base'
require 'rain/object/zone'

module Rain
    module Action

    class ListZone < Base


      def execute(param = nil)
        zones = Rain::Object::Zone.findAll
      end

    end


  end
end