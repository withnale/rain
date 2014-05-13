#require 'colored'

module Rain
  module Util
    module Format
      class Wiki



        def make_sized_string(string, width, config = {})

          return string if width == 0

          temp = string
          if config['trunc']
            temp = string.slice(0, width)
            #pp temp.length
            temp[(width-1)] = "+" if (temp.length == width)
          end

          case config['type']
            when 'center'
              output = temp.center(width)
            when 'right'
              output = temp.rjust(width)
            else
              output = temp.ljust(width)
          end
          output
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
            data[:width] = data[:width].map{|x| x.size}.max + 2
          end
          @columns << {
              :name => name,
              :opts => data
          }

        end

        def print_border_row
          if @border
            print "+"
            @columns.each do |col|
              print "#{'-' * (col[:opts][:width])}+"
            end
            print "\n"
          end
        end

        def header(border = false)
          @border = border
          border_char = "||"

          print_border_row

          print <<EOT
{table-filter:column=display,stack,component|default=ERROR,,}
{table-plus:sortIcon=true|sortColumn=5|sortDescending=true|enableHighlighting=true|columnTypes=S,S,S,S,S,S,H}
EOT

          print border_char
          @columns.each do |col|
            # TODO - work out why rubymine doesn't like colored gem
            #print "#{make_sized_string(col[:name], col[:opts][:width]).bold}#{@border_char}"
            print "#{make_sized_string(col[:name], col[:opts][:width])}#{border_char}"
          end
          print "\n"
          print_border_row
        end

        def row(list)
          #print @border_char
          print "|"
          @columns.zip(list).each do |col, data|
            #pp data
            value = data[:value].to_s
            print "{color:#{data[:color]}}" if data[:color]

            # In the world of wiki we will just print out what's required and not worry about text formatting
            #print make_sized_string(value, col[:opts][:width], { 'type' => data[:align], 'trunc' => true })
            if data[:hidden]
              print %|{expand:title=#{value}} #{data[:hidden]} {expand}|
            elsif data[:tooltip]
              print %|{tooltip:tip=#{data[:tooltip]}}#{value}{tooltip}|
            else
              print value
            end
            print "{color}" if data[:color]

            print "|"
          end
          print "\n"
        end

        def complete
          print %|{table-plus}\n|
          print %|{table-filter}\n|

        end

        def after
        end
      end

    end
  end
end
