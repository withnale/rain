require 'rain/providers/vcloud/helper'
require 'fog'

module Rain
  module Providers
    module VCloud
      class Base

        include Rain::Util::Logger

        attr_reader :handle, :vdc, :org
        @vcloud = nil

        def initialize(zone)
          @parent = zone
        end

        def getparam(key)
          @parent.config[key.to_s]
        end

        def extract_id(link)
          link[:href].split('/').last
        end

        def connect
          return if @vcloud

          username, orgname, password = getparam(:username), getparam(:org), getparam(:password)
          vdcname = getparam(:vdc)
          vcloud_host = getparam(:host)

          Fog.timeout = 1800
          vcloud_username = username + '@' + orgname

          begin
            case getparam(:ssl_verify_peer)
            when 'false', false
              connection_type = "insecure"
              Excon.defaults[:ssl_verify_peer] = false
            else 
              connection_type = "secure"
              Excon.defaults[:ssl_verify_peer] = true
            end
  
            debug { "Connecting [#{connection_type}] to VCloud: '#{vcloud_username}' for vdc '#{vdcname}'"}
            @vcloud ||= Fog::Compute::VcloudDirector.new(
                                     :vcloud_director_host     => vcloud_host,
                                     :vcloud_director_username => vcloud_username,
                                     :vcloud_director_password => password)
            debug { "Fetching VDC definitions"}
            @org ||= @vcloud.organizations.get_by_name(@vcloud.org_name)
            @vdc ||= @org.vdcs.get_by_name(vdcname)

          rescue Excon::Errors::Unauthorized => e
            raise Rain::Errors::Unauthorized, :vcloud_username => vcloud_username
          rescue Exception => e
            debug { "Boom" }
            pp e

          end
          raise Rain::Errors::UnknownVDC, :vdcname => vdcname unless @vdc
        end

        def handle
          connect
          @vcloud
        end

        def self.test
          puts "woohoo"
        end



        def edge_gateway_id
          return @edge_gateway_id if @edge_gateway_id

          connect
          edge_gateway    = Rain::Providers::VCloud::Helper.get_edge_gateway(@vcloud, @vdc)
          @edge_gateway_id = Rain::Providers::VCloud::Helper.get_edge_gateway_id(edge_gateway)
        end


      end
    end
  end
end
