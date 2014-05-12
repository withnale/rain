require 'rain/util/logging'
require 'rain/action/model/list_nat'
require 'rain/action/real/list_nat'


module Rain
  module Modellers
    module Yaml

      class Nat

        include Rain::Util::Logger

        def initialize(base)
          @model, @data = base, {}
          @strings      = []
        end


        def load
          debug { "Searching for model" }
          modeldir = @model.get_modeldir

          Dir.glob("#{modeldir}/nat/*.yaml") do |filename|
            debug { "Trying file #{filename}" }
            @strings << File.read(filename)
          end
        end


        def filter_data(data)
          @data = data
        end

        def data(env = nil)
          load

          data = @strings.each_with_object({}) do |string, hash|
            hash.deep_merge!(env ? YAML.load(env.replaceVars(string)) :  YAML.load(string))
          end
          debug { "Got data #{@data.inspect}" }
          filter_data(data)
          @data
        end

      end
    end
  end
end
