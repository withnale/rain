
module Rain
  module Modellers
    module Yaml


      class Server

        include Rain::Util::Logger

        attr_reader :data

        def initialize(base)
          @model, @data = base, {}
          @strings = []
        end


        def load_vapp_config(config_file)
          yaml_data   = YAML.load(File.read(File.join(@config_root, config_file)))
          json_string = JSON.generate(yaml_data)
          JSON.parse(json_string, :symbolize_names => true)
        end

        def load

          @modeldir = @model.get_modeldir
          debug { "Searching for model in #{@modeldir}" }

          Dir.glob("#{@modeldir}/server/*.yaml") do |filename|
            debug { "Trying file #{filename}" }
            @strings << File.read(filename)
          end
        end

        def filter_data(yaml_data)
          @data = yaml_data[:vapps].each_with_object({}) do |item,hash|
            # Add the zone to each VM
            item[:zone]         = 'zone'

            # Provide the default VDC and templates if not set
            item[:vdc_name]     ||= @yaml[:vdc]
            item[:vdc_alias]    ||= 'zonealias'
            item[:catalog]      ||= @yaml[:catalog]
            item[:catalog_item] ||= @yaml[:catalog_item]

            # 'networks' key is duplication - lets get rid of it
            item[:networks] = item[:vm][:network_connections].map{|x| x[:name]}

            # Make bootstrap path relative to model
            if item[:vm][:bootstrap] && item[:vm][:bootstrap][:script_path]
              item[:vm][:bootstrap][:script_path] = "#{@modeldir}/#{item[:vm][:bootstrap][:script_path]}"
            end
            hash[item[:name]] = item
          end
        end

        def data(env = nil)
          load
          return {} if @strings.empty? 
          yaml_data = @strings.each_with_object({}) do |string,hash|
            hash.deep_merge!(YAML.load(env ? env.replaceVars(string) :  string))
          end
          json_string = JSON.generate(yaml_data)
          @yaml = JSON.parse(json_string, :symbolize_names => true)
          filter_data(@yaml)

          @data
        end

        def get(name = nil, zone = nil)
          return @data if name.nil?
          @data.select { |x| x[:name] == name }
        end


      end

    end
  end
end
