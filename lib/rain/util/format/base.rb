

module Rain
  module Util
    module Format

      class Base

        include Util::SafePuts

        # Values to use if column isn't defined
        DEFAULT_HASH = {
            :value => '',
        }


        attr_accessor :options

        def initialize(handle = $stdout)
          @handle = handle
        end

        def before
        end

        def format(index, trow = [])
        end

        def print_border_row

        end

        def format_start_row

        end

        def format_finish_row

        end

        def parse_arg(arg)
          case arg
            when Hash
              return @arg
            when Array
              lp = 0
              hash = arg.each_with_object({}) do |item, tmphash|
                colname = item[:column] || item[:col] || @columns[lp][:name]
                item[:value] = item[:value] ? item[:value].to_s : nil
                tmphash[colname] = item
              end
              return hash
          end
        end

        def header(border = false)
          @border = border
          @border_char = @border ? "|" : " "

          print_border_row

          #safe_print @border_char
          @columns.each do |col|
            title = col[:opts][:desc] || col[:name]
            safe_print "#{make_sized_string(title, col[:opts][:width])}#{@border_char}", { :io => @handle }
          end
          safe_puts '', { :io => @handle }
          print_border_row
        end


        def column(name, config_options = nil)
          @columns ||= []
          data = {
              :width => 0
          }
          unless config_options.nil?
            data.merge!(config_options)
          end
          if data[:width].class == Array
            # Arbitrary column width if the data is empty
            data[:width] = data[:width].empty? ? 15 : data[:width].map{|x| x.to_s.size}.max + 2
          end
          return unless @columns.select{|x| x[:name] == name.to_sym }.empty?
          @columns << {
              :name => name.to_sym,
              :opts => data
          }

        end

        def format_row(rowhash)
          format_start_row
          base_hash = {}
          if @lineno
            @lineno += 1
            list.unshift({ :value => @lineno.to_s })
            base_hash = { :color => 'white' } if @lineno % 3 == 0
          end

          @columns.each do |col|
            colhash = rowhash[col[:name]] || DEFAULT_HASH
            colhash.merge!(base_hash)

            format_column_value(colhash, col[:opts][:width])
          end
          format_finish_row
        end

        def row(arg)
          rowhash = parse_arg(arg)
          format_row(rowhash)
        end

        def

        def after
        end


      end

    end
  end
end
