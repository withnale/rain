require 'jsonpath'
require 'json'


module Rain
  module Util

    class JsonPath

      def self.first(object, jsonpath)
        JsonPath.on(object.to_json, jsonpath).first
      end

      def self.all(object, jsonpath)
        JsonPath.on(object.to_json, jsonpath)
      end

      def initialize(object)
        @object = object
      end

      def first(jsonpath)
        JsonPath.on(@object.to_json, jsonpath).first
      end

      def all(jsonpath)
        JsonPath.on(@object.to_json, jsonpath)
      end


    end

  end
end
