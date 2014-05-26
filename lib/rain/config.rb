require 'pp'
require 'awesome_print'
require 'yaml'
require 'jsonpath'
require 'json'


module Rain

    # Base class for any CLI commands.
    #
    # This class provides documentation on the interface as well as helper
    # functions that a command has.
    class Config

      CONFIG_FILE_DEFAULTS = "etc/rainrc"
      CONFIG_FILE_HOMERC   = "#{ENV['HOME']}/.rainrc"

      DEEP_MERGE_OPTIONS = {
          #   :merge_debug => true,
          :merge_hash_arrays => true
      }

      # Get the base directory for rain i.e the top-level / git-root for the project
      # Aruba seems to change the default startup directory during testing so
      # we need to make sure all file references are absolute
      def self.basedir
        @basedir
      end

      def self.set_global_option(name, value)
        @data ||= {}
        @data[name.to_sym] = value
      end

      def self.get_global_option(name)
        @data ||= {}
        @data[name.to_sym]
      end

      def self.config
        full_config_load unless @config
        @config
      end

      def self.findpath(jsonpath)
        JsonPath.on(config.to_json, jsonpath).first || []
      end


      def self.zonepaths

        zonepath = ENV['MODELDIR'].split(':') rescue nil
        zonepath ||= findpath("$.config.zonepath")
        zonepath ||= [ '../rain-model' ]

        zonepath.map!{|x| File.expand_path(x, Rain::Config.basedir) }
        zonepath
      end

      def self.full_config_load
        self.full_config_load_internal
      end

      def self.full_config_load_internal
        @config = {}

        load_config!(CONFIG_FILE_DEFAULTS)
        if File.exists?("#{CONFIG_FILE_HOMERC}.gpg")
          load_config!("#{CONFIG_FILE_HOMERC}.gpg", :optional)
        else
          load_config!(CONFIG_FILE_HOMERC, :optional)
        end

        zonepaths.each do |path|
          load_config!("#{path}/rain.yaml", :optional)
        end
      end

      def self.load_from_file(filepath)
        if  filepath.end_with?('.gpg')
          require 'gpgme'
          crypto = GPGME::Crypto.new
          crypto.decrypt(File.open(filepath)).to_s
        else
          File.read(filepath)
        end
      end

      def self.load_config!(filename = CONFIG_FILE_DEFAULTS, present = nil)
        filepath = File.expand_path(filename, @basedir)

        begin
          Rain::Util::RainLogger.debug {"loading config from #{filepath}"}
          hash = YAML::load(self.load_from_file(filepath))
          Rain::Util::RainLogger.debug { hash.pretty_print_inspect }

          @config.deep_merge!( hash, DEEP_MERGE_OPTIONS)
          Rain::Util::RainLogger.debug { @config.pretty_print_inspect }
        rescue Errno::ENOENT => e
          warn "Cannot load #{filename} [#{filepath}]" unless present == :optional
        end

      end


      def self.set_base_directory(filename)
        @basedir = File.expand_path('../..', File.dirname(filename))
      end

      def load_model_provider(name)

      end


      def load_cloud_provider(name)
      end


    end
end
