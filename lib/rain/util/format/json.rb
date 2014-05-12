
module Rain
  module Util
    module Format
      class Json < Base

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
          safe_puts JSON.pretty_generate(@list)
        end

        def after

        end
      end



    end
  end
end
