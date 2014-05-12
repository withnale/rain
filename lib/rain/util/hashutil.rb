require 'json'

module Rain
  module Util
    class HashUtil

      def self.to_sym(object, env = nil)
        if env
          json_string = env.replaceVars(JSON.generate(object))
        else
          json_string = JSON.generate(object)
        end
        JSON.parse(json_string, :symbolize_names => true)
      end

    end
  end
end
