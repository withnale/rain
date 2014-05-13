
module Rain
  module Util
    module Format
      class Yaml < Base

        attr_accessor :options

        def before
        end


        def header(border = false)
          @list = []
        end

        def format_row(hash)
          @list << hash.values
        end

        def complete
          safe_puts @list.to_yaml
        end

        def after

        end
      end



    end
  end
end
