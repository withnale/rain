require 'logger'


module Rain

  module Util

    class CleanInfoFormatter < Logger::Formatter
      # Provide a call() method that returns the formatted message.
      def call(severity, time, program_name, message)
        if severity == "INFO"
          "#{String(message)}\n"
        elsif program_name
          "#{severity} --: [#{program_name}] #{String(message)}\n"
        else
          "#{severity} --: #{String(message)}\n"
        end
      end
    end

    class RainLogger
      attr_accessor :logger

      @@debug_all        = false
      @@debug_tags       = []
      @@logger           = Logger.new(STDERR)
      @@logger.formatter = CleanInfoFormatter.new

      def initialize
        super(@@logger)
      end

      def self.setup(hash)
        @@verbose    = hash[:verbose]
        @@debug_all  = hash[:debug]
        @@debug_tags = hash['debug-tags'] ? hash['debug-tags'].map { |x| x.to_sym } : []
      end

      def self.debug_level=(value)
        @@debug_level = value.to_i
      end

      def self.set_logger(logger)
        @@logger = logger
        __setobj__(@@logger)
      end

      def self.warn(message = nil, &block)
        @@logger.log(::Logger::WARN, message, nil, &block)
      end

      def self.info(message = nil, &block)
        @@logger.log(::Logger::INFO, message, nil, &block)
      end

      def self.verbose(message = nil, &block)
        return unless @@verbose
        @@logger.log(::Logger::INFO, message, nil, &block)
      end


      def self.debug(tag = nil, message = nil, multi_line = nil, &block)
        if @@debug_all || @@debug_tags.include?(tag)
          # If we are printing multiline block output it should be to info
          if multi_line
            @@logger.log(::Logger::INFO, message, tag, &block)
          else
            @@logger.log(::Logger::DEBUG, message, tag, &block)
          end
        end
      end

    end


    # This is intended to be used as a mixin by adding
    #    include Vcb::Util::Logger
    # to your base classes

    module Logger

      def debug(arg1 = nil, arg2 = nil, &block)
        if ENV['RAINDEBUG_LINES']
          Rain::Util::RainLogger.debug { "Debugging from [#{caller[3]}"}
        end
        case arg1
          when Symbol
            Rain::Util::RainLogger.debug(arg1, arg2, &block)
          else
            Rain::Util::RainLogger.debug(arg1, nil, &block)
        end
      end

      def debug_ml(arg1 = nil, arg2 = nil, &block)
        if ENV['RAINDEBUG_LINES']
          Rain::Util::RainLogger.debug { "Debugging from [#{caller[3]}]"}
        end
        case arg1
          when Symbol
            tag  = arg1
            mess = arg2 || 'Debug Block'
            Rain::Util::RainLogger.debug(arg1, arg2, &block)
          else
            mess = arg1 || 'Debug Block'
            Rain::Util::RainLogger.debug(arg1, nil, &block)
        end
        Rain::Util::RainLogger.debug(tag, "<<< #{mess} [Start]")
        Rain::Util::RainLogger.debug(tag, nil, true, &block)
        Rain::Util::RainLogger.debug(tag, ">>> #{mess} [Stop]")

      end

      def verbose(mess = nil, &block)
        Rain::Util::RainLogger.verbose(mess, &block)
      end

      def warning(mess = nil, &block)
        Rain::Util::RainLogger.warn(mess, &block)
      end


    end
  end


end
