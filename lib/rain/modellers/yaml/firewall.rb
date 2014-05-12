require 'rain/util/logging'

module Rain
  module Modellers
    module Yaml

      class Firewall

        include Rain::Util::Logger

        def initialize(base)
          @model, @data = base, {}
          @strings      = []
        end

        def load
          debug { "Searching for model" }
          modeldir = @model.get_modeldir

          Dir.glob("#{modeldir}/firewall/*.yaml") do |filename|
            debug { "Trying file #{filename}" }
            @strings << File.read(filename)
          end
        end


        def filter_data(data)
          @data                                  = Marshal.load(Marshal.dump(data))
          @data[:FirewallService][:FirewallRule] = []
          data[:FirewallService][:FirewallRule].each do |rule|
            unless rule[:Enabled].nil?
              case rule[:Enabled]
                when false, 'false', 0, '0'
                  next
              end
            end
            rule.delete(:Enabled)

            srcport = rule[:SourcePort].class == Array ? rule[:SourcePort] : [rule[:SourcePort]]
            dstport = rule[:DestinationPortRange].class == Array ? rule[:DestinationPortRange] : [rule[:DestinationPortRange]]
            srcaddr = rule[:SourceIp].class == Array ? rule[:SourceIp] : [rule[:SourceIp]]
            dstaddr = rule[:DestinationIp].class == Array ? rule[:DestinationIp] : [rule[:DestinationIp]]

            srcaddr.each do |tmp_srcaddr|
              dstaddr.each do |tmp_dstaddr|
                srcport.each do |tmp_srcport|
                  dstport.each do |tmp_dstport|
                    tmprule                                              = rule.clone
                    tmprule[:SourcePort], tmprule[:DestinationPortRange] = tmp_srcport, tmp_dstport
                    tmprule[:SourceIp], tmprule[:DestinationIp]          = tmp_srcaddr, tmp_dstaddr

                    @data[:FirewallService][:FirewallRule] << tmprule
                  end
                end
              end
            end
          end
        end

        def data(env = nil)
          load

          data = @strings.each_with_object({}) do |string, hash|
            hash.deep_merge!(env ? YAML.load(env.replaceVars(string)) : YAML.load(string))
          end
          debug { "Got data #{@data.inspect}" }
          filter_data(data)
          @data
        end

      end
    end
  end
end
