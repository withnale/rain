require 'rain/action/base'
require 'rain/object/zone'
require 'rain/errors'
#require 'rain/providers/vcloud/helper'


module Rain
  module Action
    module Real

      class UploadImage < Rain::Action::Base

        def execute(filename, zones)

          # Before we pass this on to the provider do some basic sanity checking
          # 1. We only need to upload it once to a given Org - remove duplicate zones
          # 2. Ensure the file actually exists

          target_orgs = []
          upload_zones = zones.select do |zone|
            if target_orgs.include? zone.config['org']
              puts "#{zone.config['org']} => '#{zone.config['vdc']}' : Org already present - skipping"
              false
            else
              puts "#{zone.config['org']} => '#{zone.config['vdc']}' : "
              target_orgs << zone.config['org']
              true
            end
          end
          unless File.exists? filename
            raise Rain::Errors::NoSuchFile, :filename => filename
          end

          image = zone.get(:image)
          image.upload(filename, upload_zones)
        end

      end

    end
  end
end
