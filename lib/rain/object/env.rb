require 'rain/config'
require 'rain/object/model'
require 'pp'

module Rain
  module Object

    class Env

      @@collection = {}

      attr_reader :name, :type, :config, :zone, :model, :variables

      def initialize(name, config = {})
        @name = name
        @variables = {}

        case config
          when String
             @type = 'simple'
             zonename = config
             modelname = @name
             
          when Hash
             config = Rain::Util::HashUtil.to_sym(config)
             @type = config['type'] || 'simple'
             zonename = config[:zone]
             modelname = config[:model] || @name
             @variables = config[:variables] || {}

          when Array
            @type = 'multi'
        end
        @variables[:zonename] = zonename
        @variables[:modelname] = modelname
        @variables[:envname] = @name


        @zone  = Rain::Object::Zone.get(zonename) if zonename
        @model = Rain::Object::Model.get(modelname) if modelname
        @variables = merged_variables

        @@collection[@name] = self
      end

      def replaceVars(string)
        string.gsub(/%{(\w+)}/) do
          variables = merged_variables
          unless variables[$1.to_sym]
            raise Rain::Errors::NoSuchVariable, :variable => $1, :env => @name
          end
          variables[$1.to_sym]
        end
      end

      def merged_variables
          @zone ? @zone.variables.merge(@variables) : @variables
      end

      def self.get(name)
        @@colection ||= {}
        @@collection[name] || self.find(name)
      end

      def self.find(arg)
        retval = nil
        Rain::Config.findpath("$.envs").select {|name, _| name == arg }.each do |name,data|
          retval = new(name, data)
        end
        retval
      end

      def self.findAll
        envs = Rain::Config.findpath("$.envs") || {}
        envs.each do |name,data|
          new(name, data)
        end

        @@collection
      end



    end
  end
end
