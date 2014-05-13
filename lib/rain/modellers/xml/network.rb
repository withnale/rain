module Rain
  module Modellers
    module Xml


      class Network

        include Rain::Util::Logger

        attr_reader :data

        def initialize(base)
          @model, @data = base, {}
        end

        def load(env = nil)

          @data = []
          # There should be a directory
          begin

            debug { "Searching for model" }
            modeldir = @model.get_modeldir

            Dir.glob("#{modeldir}/network/*.xml") do |file|

              network_name = File.basename(file, '.xml')
              debug { "Found network #{network_name}" }
              network_data = File.read(file)
              if env
                 network_data = env.replaceVars(network_data)
              end
              # Quick and dirty way to collect the data - might move this to yaml later anyway
              gateway      = network_data.scan(%r{<Gateway>([^<]+)</Gateway>}).flatten.first
              netmask      = network_data.scan(%r{<Netmask>([^<]+)</Netmask>}).flatten.first
              fenced       = network_data.scan(%r{<FenceMode>([^<]+)</FenceMode>}).flatten.first

              range_start = network_data.scan(%r{<StartAddress>([^<]+)</StartAddress>}).flatten.first
              range_end   = network_data.scan(%r{<EndAddress>([^<]+)</EndAddress>}).flatten.first

              network = {
                  :name          => network_name,
                  :data          => network_data,
                  :netmask       => netmask,
                  :gateway       => gateway,
                  :start_address => range_start,
                  :end_address   => range_end,
                  :fenced        => fenced
              }
              @data << network
            end
            # rescue
          end
          @data
        end

        def data(env = nil)
          load(env)
          @data.sort_by{|x| x[:name] }
        end


      end
    end
  end
end
