require 'cgi'

module Rain
  module Util
    module Format
      class Html

        attr_accessor :options

        include Util::SafePuts


        def initialize
          @header_string = "<table>\n"
        end

        def make_sized_string(string, width, config = {})

          classes = []
          classes << config['type'] if config['type']
          classes << config['color'] if config['color']

          class_string = classes.empty? ? '' : " class=\"#{classes.join(';')}\""

          "<td#{class_string}> #{CGI::escape_html(string)} </td>"

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

        def print_border_row
          if @border
            safe_print '+'
            @columns.each do |col|
              safe_print "#{'-' * (col[:opts][:width])}+"
            end
            safe_puts
          end
        end

        def header(border = false)

          @header_string << "<thead>\n<tr>"

          @columns.each do |col|
            @header_string << "#{make_sized_string(col[:name], col[:opts][:width])}#{@border_char}"
          end

          @header_string << "</tr>\n</thead>\n"

        end

        def row(list)
          if @header_string
            safe_puts @header_string
            safe_puts '<tbody>'
            @header_string = nil
          end

          safe_print '<tr>'
          @columns.zip(list).each do |col, data|
            #pp data
            value = data[:value].to_s
            safe_print "#{make_sized_string(value, col[:opts][:width], { 'type' => data[:align], 'trunc' => true,
                                                                         'color' => data[:color]
            })}"
          end
          safe_puts "</tr>"
        end

        def complete
          safe_puts '</tbody>'
          safe_puts '</table>'
        end

        def after

        end
      end

    end
  end
end
