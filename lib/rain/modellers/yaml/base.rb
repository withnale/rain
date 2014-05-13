require 'rain/util/logging'

#require_relative 'firewall'
require_relative 'nat'
require_relative 'network'
require_relative 'server'


module Rain
  module Modellers
    module Yaml
      class Base

        IMPLCLASSES = {
            :firewall => Rain::Modellers::Yaml::Firewall,
            :network  => Rain::Modellers::Yaml::Network,
            :nat      => Rain::Modellers::Yaml::Nat,
            :server   => Rain::Modellers::Yaml::Server
        }

        @@defaults = {}

        include Rain::Util::Logger

        attr_reader :handle, :vdc, :org, :parent
        @vcloud = nil

        def initialize(zone)
          @parent = zone
        end

        def getparam(key)
          @parent.config[key.to_s] || @@defaults[key.to_s]
        end

        def self.test
          puts "woohoo"
        end

        def self.set_defaults(hash)
          @@defaults = hash
        end

        def self.get_defaults
          @@defaults ||= {}
          @@defaults
        end

        def get_firewall
          Rain::Modellers::Yaml::Firewall.new(self)
        end

        def get(param)
          IMPLCLASSES[param].new(self)
        end
      end
    end
  end
end