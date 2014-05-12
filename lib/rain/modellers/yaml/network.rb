
module Rain
  module Modellers
    module Yaml


      class Network

        attr_reader :data

        def initialize(model)
          @model = model
          @data  = nil

        end


        def load_zone(zone)

          networks = []
          # There should be a directory
          begin
            Dir.glob("#{@model.basedir}/config/#{zone[:zone]}/network/*.xml") do |file|
              network_name = File.basename(file, '.xml')

              network_data = File.read(file)
              # Quick and dirty way to collect the data - might move this to yaml later anyway
              gateway = network_data.scan(%r{<Gateway>([^<]+)</Gateway>}).flatten.first
              netmask = network_data.scan(%r{<Netmask>([^<]+)</Netmask>}).flatten.first
              fenced  = network_data.scan(%r{<FenceMode>([^<]+)</FenceMode>}).flatten.first

              network = {
                  :zone => zone[:zone],
                  :name => network_name,
                  :data => network_data,
                  :netmask => netmask,
                  :gateway => gateway,
                  :fenced => fenced

              }
              networks << network
            end
          # rescue

          end

          networks
        end

        def load

          @data = []
          @data = @model.zones.data.each_with_object([]) do |zone, list|
            list += load_zone(zone)
          end
          @data

        end


        def self.from_config(*args)
          object = allocate
          object.from_config(*args)
          object
        end

        def from_config(network_name, zone, file, vcloud_context)
          @name           = network_name
          @zone           = zone
          @vcloud_context = vcloud_context

        end


      end
    end
  end
end
