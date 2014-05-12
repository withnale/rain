require 'rain/util/format/base'
require 'rain/util/format/csv'
require 'rain/util/format/json'
require 'rain/util/format/yaml'
require 'rain/util/format/pretty'
require 'rain/util/format/table'
require 'rain/util/format/wiki'
require 'rain/util/format/html'

module Rain
  module Util
    module Format

      FORMATTERS = {
          'yaml'   => Rain::Util::Format::Yaml,
          'json'   => Rain::Util::Format::Json,
          'table'  => Rain::Util::Format::Table,
          'csv'    => Rain::Util::Format::CSV,
          'pretty' => Rain::Util::Format::Pretty,
          'wiki'   => Rain::Util::Format::Wiki,
          'html'   => Rain::Util::Format::Html,
      }

      DATEFORMATTERS = {
          'diff'     => 'diff',
          'default'  => "%a-%d-%b-%y %H:%M",
          'short'    => "%d-%b-%y %H:%M"
      }


    end
  end
end
