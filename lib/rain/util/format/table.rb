require_relative 'base'

module Rain
  module Util
    module Format
      class Table < Base

        def options=(param)
          @options = param
          if param[:lineno]
            column('Line', { :width => 4 })
            @lineno = 0
          end
        end


        def make_sized_string(string, width, config = {})

          if width == 0
            temp = string.to_s.dup
          elsif config['trunc']
            temp = string.slice(0, width)
            #pp temp.length
            temp[(width-1)] = "+" if (temp.length == width)
          else
            temp = string.to_s.dup
          end

          # Apply position
          if width == 0
            output = temp
          else
            case config['type']
              when 'center'
                output = temp.center(width)
              when 'right'
                output = temp.rjust(width)
              else
                output = temp.ljust(width)
            end
          end

          if config['color']
            output.colorize(config['color'])
          else
            output
          end

        end


        def print_border_row
          if @border
            @handle.print "+"
            @columns.each do |col|
              @handle.print "#{'-' * (col[:opts][:width])}+"
            end
            $handle.print "\n"
          end
        end

        def format_column_value(hash, width)
          #pp hash
          safe_print "#{make_sized_string(hash[:value].to_s, width, {})}#{@border_char}", { :io => @handle }
        end

        def format_finish_row
          safe_puts '', { :io => @handle }
        end

        def complete
          print_border_row
        end

        def after

        end
      end

    end
  end
end
