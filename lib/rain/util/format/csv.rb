
module Rain
  module Util
    module Format
      class CSV

        attr_accessor :options

        def before
        end

        def column(name, config_options = nil)
          @columns ||= []
          data = {
              :width => 0
          }
          unless config_options.nil?
            data.merge!(config_options)
          end
          @columns << {
              :name => name,
              :opts => data
          }

        end

        def header(border = false)

          print @columns.map{ |x| x[:name]}.join(','), "\n"
        end

        def row(list)
          print list.map{ |x| x[:value]}.join(','), "\n"
        end

        def complete
        end

        def after

        end
      end



    end
  end
end
