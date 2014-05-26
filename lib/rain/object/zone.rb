require 'rain/config'
require 'pp'

module Rain
  module Object

    class Zone

      @@collection = {}

      attr_reader :name, :type, :config, :impl, :variables

      def initialize(name, data = {})

        @name = name

        @implclass = {}
        @impl = {}

        variables = data.delete('variables') || {}
        @variables = Rain::Util::HashUtil.to_sym(variables)
        @zone_type = data.keys.first

        @confirmcode = data['confirmcode']
        @config = Rain::Config.findpath("$.providers.#{@zone_type}")
        @config.merge!(data[@zone_type])

        @@collection[@name] = self
      end

      def to_s
        @name
      end

      def get(type)
        return @impl[type] if @impl[type]
        class_name = Rain::Config.findpath("$.implementations.providers.#{@zone_type}.#{type}")

        begin
          unless @implclass[type]
            @implclass[type] = Rain::Util::DynamicCreate.from_string(class_name, :require)
          end
          @impl[type] = @implclass[type].new(self)
        rescue LoadError
          raise Rain::Errors::NoSuchZoneClass, :class => class_name
        end
        @impl[type]

      end

      def zone_check(options)
        # Raise an error if a confirmcode exists and is not provided
        return if @confirmcode == nil || options[:confirmcode] == @confirmcode
        raise Rain::Errors::SafetyCheckFailed, :confirmcode => @confirmcode
      end


      def self.get(name)
        #@@collection ||= {}
        @@collection[name] || self.find(name)
      end


      def self.find(arg)
        retval = nil
        Rain::Config.findpath("$.zones").select {|name, _| name == arg }.each do |name,data|
          retval = new(name, data)
        end
        retval
      end

      def self.findAll
        matches = Rain::Config.findpath("$.zones") || {}
        matches.each do |name,data|
          retval = new(name, data)
        end

        @@collection
      end



    end
  end
end
