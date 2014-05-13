require 'vcb/models/yaml/zones'
require 'vcb/models/yaml/vapps'
require 'vcb/models/yaml/networks'
require 'vcb/models/yaml/firewall'
require 'vcb/models/yaml/nat'

module Vcb
  module Models
    module Yaml


      class Model

        attr_reader :location, :env

        def initialize
          #puts "Creating YAML model"
        end

        def set_environment(location, env)
          @location = location
          @env = env

          # Check the directory
          unless Dir.exists?(@location)
            raise Vcb::Errors::ConfigMissing
          end

          # Check the directory
          unless Dir.exists?(basedir)
            raise Vcb::Errors::EnvMissing
          end

        end

        def basedir
          "#{@location}/#{@env}"
        end

        def networks
          return @networks if @networks
          #puts "Getting network model"

          @networks = Networks.new(self)
          @networks.load
          @networks
        end

        def zones
          #puts "Getting zones"
          return @zones if @zones

          @zones = Zones.new(self)
          @zones.load
          @zones
        end

        def vapps
          #puts "Getting vapps"
          return @vapps if @vapps

          @vapps = Vapps.new(self)
          @vapps.load
          @vapps
        end

        def firewall
          #puts "Getting vapps"
          return @firewall if @firewall

          @firewall = Firewall.new(self)
          @firewall.load
          @firewall
        end

        def nat
          #puts "Getting vapps"
          return @nat if @nat

          @nat = Nat.new(self)
          @nat.load
          @nat
        end



      end

    end
  end
end
