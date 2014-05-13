require 'vcb/models/yaml/model'
require 'vcloud'

module Rain
  module Modellers
    module Yaml


      class Zones

        attr_reader :data

        def initialize(model)
          @model = model

        end

        def load
          config_file  = File.join(@model.basedir, "config.yaml")
          #puts "Loading config from #{config_file}"
          @data = YAML.load_file(config_file)
          @data.each {|x| fog(x[:zone])}
        end

        def get(name)
          @data.select {|x| x[:zone] == name }
        end

        def fog(name)
          zone = get(name)
          return zone.first[:fog] if zone.first[:fog]

          Fog.credential = zone.first[:credential]
          zone.first[:fog] = Vcloud::FogInterface.new
        end


      end

    end
  end
end
