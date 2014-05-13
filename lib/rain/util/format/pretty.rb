
module Rain
  module Util
    module Format
      class Pretty

        attr_accessor :options

        def before
          @@table = Terminal::Table.new
          @@table.align_coend
        end

        def format(index, trow = [])
          row << index
          row << task.name
          row << ''
        end


        def after

        end
      end

    end
  end
end
