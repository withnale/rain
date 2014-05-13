require 'rain/config'
require 'pp'

module Rain
  module Object

    class Model

      @@collection = {}

      attr_reader :name, :type, :config, :impl

      def initialize(name, model_type = nil, config = nil)
        @name, @config = name, config
        @implclass = {}
        @impl = {}

        @model_type = model_type || Rain::Config.findpath("$.implementations.default.model")

        @@collection[@name] = self
      end


      def get(type)
        return @impl[type] if @impl[type]

        # TODO: Add the ability to pass in variables to the model area subclass
        class_name = Rain::Config.findpath("$.implementations.modellers.#{@model_type}.#{type}")
        begin
          unless @implclass[type]
            @implclass[type] = Rain::Util::DynamicCreate.from_string(class_name, :require)
          end
          @impl[type] = @implclass[type].new(self)
        rescue LoadError
          raise Rain::Errors::NoSuchModelClass, :class => class_name
        end
        @impl[type]

      end

      def get_modeldir
        zonepaths = Rain::Config.zonepaths

        # Search for this model somewhere on the zonepath
        zonepaths.each do |zonepath|
          if Dir.exists? "#{zonepath}/#{@name}"
            return "#{zonepath}/#{@name}"
          end
        end
        raise Rain::Errors::ModelNotFound, :model => @name
      end

      def self.get_defaults

        @@defaults ||= Rain::Config.findpath('$.config')
        @@defaults
      end



      def to_s
        @name
      end


      def self.get(name)
        @@collection ||= {}
        return @@collection[name] if @@collection[name]
        new(name)
      end

      def self.check(name)
        @@collection ||= {}
        @@collection[name]
      end

=begin
      def self.findAll
        Rain::Config.findpath("$.zones").each do |name,data|
          type = data.keys.first
          config = data[type]
          new(name, type, config)
        end

        pp @@collection
      end
=end

   end
  end
end
