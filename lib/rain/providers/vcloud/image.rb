require 'rain/providers/vcloud/base'

module Rain
  module Providers
    module VCloud
      class Image < Base



        def data
          return @data if @data

          foginterface = Vcloud::FogInterface.new(handle)

          _catalogs = foginterface.org[:Link].select { |l| l[:rel] == 'down' && l[:type] == Vcloud::ContentTypes::CATALOG }
          @data = _catalogs.each_with_object([]) do |l, list|
            catalog = foginterface.catalog(l[:name])[:CatalogItems][:CatalogItem]
            catalog.each do |x|
              x[:id] = extract_id(x)
              x[:catalog] = l[:name]
            end
            list.push(*catalog)
          end
        end

        def show
          data
        end

      end
    end
  end
end
