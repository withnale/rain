
module Rain

  module Util

    class DynamicCreate

      # Rain::Util::DynamicCreate.from_string()
      def self.from_string(class_name, include_require = nil)
        begin
          if include_require
            require_name = class_name.gsub(/::/,'/').downcase
            require require_name
          end
          class_name.split('::').inject(Kernel) {|scope, const_name| scope.const_get(const_name)}
        rescue NameError => e
          raise Rain::Errors::UnknownPlugin, :plugin => class_name
        end
      end
    end
  end
end