require 'rain/util/logging'
module Rain
  module Providers
    module VCloud

      class Helper

        include Rain::Util::Logger
        def self.get_edge_gateway(vcloud, vdc)
          return vcloud.get_org_vdc_gateways(vdc.id).body.fetch(:EdgeGatewayRecord).first
        end

        def self.get_edge_gateway_id(edge_gateway)
          return edge_gateway.fetch(:href).split('/').last
        end

        def self.get_edge_gateway_body(vcloud, edge_gateway_id, edge_gateway_network_name)
          edge_gateway_config_body = vcloud.get_edge_gateway(edge_gateway_id).body
          edge_gateway_config_body
        end


        def self.create_network(config, vdc_id, edge_gateway_id, token, network)

          url     = "https://#{config['host']}/api/admin/vdc/#{vdc_id}/networks"
          headers = {
              'Accept'                 => 'application/*+xml;version=1.5',
              'Content-Type'           => 'application/vnd.vmware.vcloud.orgVdcNetwork+xml',
              'x-vcloud-authorization' => token
          }
          puts "Creating network '" + network[:name] + "'..."

          postdata = network[:data]
          postdata.gsub!(/VCLOUD_EDGE_GATEWAY_ID/, edge_gateway_id)
          postdata.gsub!(/VCLOUD_API_HOST/, config['host'])

          Rain::Util::RainLogger.debug { postdata }
          response = Excon.post(url, :body => postdata, :headers => headers)
          if response.status != 201
            puts " Couldn't create network '" + network[:name] + "'"
            return nil
          else
            network_url = response.get_header('location')
            poll_until_complete(network_url, headers)
            puts " Done."
            return network_url
          end
        end


        def self.get_edge_gateway_uri(vcloud, edge_gateway_id, edge_gateway_network_name = nil)
          edge_gateway_uri         = nil
          edge_gateway_config_body = vcloud.get_edge_gateway(edge_gateway_id).body
          edge_gateways            = edge_gateway_config_body[:Configuration][:GatewayInterfaces][:GatewayInterface]
          edge_gateways.each do |network|
            if network.fetch(:InterfaceType) == 'uplink'
              return network[:Name], network[:Network][:href]
            end
          end
          raise StandardError
        end

        def self.get_edge_gateway_uri_old(vcloud, edge_gateway_id, edge_gateway_network_name)
          edge_gateway_uri         = nil
          edge_gateway_config_body = vcloud.get_edge_gateway(edge_gateway_id).body
          edge_gateways            = edge_gateway_config_body[:Configuration][:GatewayInterfaces][:GatewayInterface]
          edge_gateways.each do |network|
            if network.fetch(:Name) == edge_gateway_network_name
              edge_gateway_uri = network[:Network][:href]
            end
          end
          edge_gateway_uri
        end

        def self.get_firewall(vcloud, edge_gateway_id)
          edge_gateway_config_body = vcloud.get_edge_gateway(edge_gateway_id).body
          edge_gateway_config_body[:Configuration][:EdgeGatewayServiceConfiguration][:FirewallService]
        end


        def self.get_nat(vcloud, edge_gateway_id)
          edge_gateway_config_body = vcloud.get_edge_gateway(edge_gateway_id).body
          result = edge_gateway_config_body[:Configuration][:EdgeGatewayServiceConfiguration][:NatService]

          return result if result
          return { :NatRule => [] }
        end

        def self.get_lb(vcloud, edge_gateway_id)
          edge_gateway_config_body = vcloud.get_edge_gateway(edge_gateway_id).body
          edge_gateway_config_body[:Configuration][:EdgeGatewayServiceConfiguration][:LoadBalancerService]
        end

        def self.get_network(vcloud, edge_gateway_id)
          edge_gateway_config_body = vcloud.get_edge_gateway(edge_gateway_id).body
          edge_gateway_config_body[:Configuration][:GatewayInterfaces][:GatewayInterface]
        end

        def self.poll_until_complete(poll_url, headers, match_string = '<Tasks>')
          loop do
            print '.'
            sleep 1
            poll_response = Excon.get(poll_url, :headers => headers)
            break unless poll_response.body.include? match_string
          end
        end


        def configure_vapps(fog_interface, zone)
          puts "Provisioning vApps..." if @options[:verbose]
          config = load_vapp_config("config/#{zone}/vapp/vapp.yaml")


          puts "%-20s  %-20s  %s " % ['name', 'status', 'template/network'] if @options[:action] == 'list'

          config[:vapps].each do |vapp_config|
            begin
              configure_vapp_instance(vapp_config, config)
            rescue => exception
              puts "Error processing vApp #{vapp_config[:name]}"
              puts exception.backtrace if @options[:verbose] || @options[:debug]
            end
          end
        end


      end
    end
  end
end