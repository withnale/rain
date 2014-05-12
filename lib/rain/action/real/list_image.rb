require 'rain/action/base'
require 'rain/object/zone'
require 'rain/errors'
#require 'rain/providers/vcloud/helper'


module Rain
  module Action
    module Real

      class ListImage < Rain::Action::Base

        def execute(zone)
          image = zone.get(:image)
          image.show
        end

      end

    end
  end
end
