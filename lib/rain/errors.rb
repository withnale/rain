require 'i18n'
# This file contains all of the internal errors in Emo's core
# commands, actions, etc.

module Rain
  # This module contains all of the internal errors in Emo's core.
  # These errors are _expected_ errors and as such don't typically represent
  # bugs in Emo itself. These are meant as a way to detect errors and
  # display them in a user-friendly way.
  #
  # # Defining a new Error
  #
  # To define a new error, inherit from {EmoError}, which lets Emo
  # know that this is an expected error, and also gives you some helpers for
  # providing exit codes and error messages. An example is shown below, then
  # it is explained:
  #
  #     class MyError < Emo::Errors::EmoError
  #       error_key "my_error"
  #     end
  #
  # This creates an error with an I18n error key of "my_error." {EmoError}
  # uses I18n to look up error messages, in the "Emo.errors" namespace. So
  # in the above, the error message would be the translation of "Emo.errors.my_error"
  #
  # If you don't want to use I18n, you can override the {#initialize} method and
  # set your own error message.
  #
  # # Raising an Error
  #
  # To raise an error, it is nothing special, just raise it like any normal
  # exception:
  #
  #     raise MyError.new
  #
  # Eventually this exception will bubble out to the `Emo` binary which
  # will show a nice error message. And if it is raised in the middle of a
  # middleware sequence, then {Action::Warden} will catch it and begin the
  # recovery process prior to exiting.
  module Errors
    # Main superclass of any errors in Emo. This provides some
    # convenience methods for setting the status code and error key.
    # The status code is used by the `Emo` executable as the
    # error code, and the error key is used as a default message from
    # I18n.
    class RainError < StandardError
      @@used_codes = []

      def self.status_code(code = nil)
        if code
          raise "Status code already in use: #{code}" if @@used_codes.include?(code)
          @@used_codes << code
        end

        define_method(:status_code) { code }
      end

      def self.error_key(key=nil, namespace=nil)
        define_method(:error_key) { key }
        error_namespace(namespace) if namespace
      end

      def self.error_namespace(namespace)
        define_method(:error_namespace) { namespace }
      end

      def initialize(message=nil, *args)
        message = {:_key => message} if message && !message.is_a?(Hash)
        message = {:_key => error_key, :_namespace => error_namespace}.merge(message || {})
        message = translate_error(message)

        super
      end

      def print_message
        puts message
      end

      # The default error namespace which is used for the error key.
      # This can be overridden here or by calling the "error_namespace"
      # class method.
      def error_namespace;
        "rain.errors";
      end

      # The key for the error message. This should be set using the
      # {error_key} method but can be overridden here if needed.
      def error_key;
        nil;
      end

      protected

      def translate_error(opts)
        return nil unless opts[:_key]
        I18n.t("#{opts[:_namespace]}.#{opts[:_key]}", opts)
      end
    end


    class InvalidCommand < RainError
      status_code(101)
      error_key(:invalidcommand)
    end

    class HelpText < RainError
      status_code(0)
      error_key(:helptext)
    end

    class NoSuchFile < RainError
      status_code(1002)
      error_key(:nosuchfile)
    end

    class NoParameters < RainError
      status_code(1005)
      error_key(:no_parameter)
    end

    class ErrorHelpText < StandardError
      attr_reader :args
      def initialize(args)
        @args = args
      end
    end

    class ModelNotFound < RainError
      status_code(1003)
      error_key(:model_not_found)
    end

    class UnknownRelease < RainError
      status_code(18)
      error_key(:release_not_specified)
    end

    class ReleaseUnknown < RainError
      status_code(14)
      error_key(:release_unknown)
    end

    class ReleaseExists < RainError
      status_code(13)
      error_key(:release_exists)
    end

    class NoSuchServer < RainError
      status_code(2)
      error_key(:no_such_server)
    end

    class NoMatches < RainError
      status_code(22)
      error_key(:no_matches)
    end

    class NoMetadata < RainError
      status_code(23)
      error_key(:no_metadata)
    end

    class DuplicateChange < RainError
      status_code(24)
      error_key(:duplicate_change)
    end

    class ComponentNotDefined < RainError
      status_code(25)
      error_key(:component_not_defined)
    end

    class UnknownVDC < RainError
      status_code(26)
      error_key(:nosuchvdc)
    end

    class InvalidParameter < RainError
      status_code(57)
      error_key(:invalid_parameter)
    end

    class Unauthorized < RainError
      status_code(15)
      error_key(:unauthorized)
    end

    class Timeout < RainError
      status_code(68)
      error_key(:timeout)
    end

    class CLIInvalidUsage < RainError
      status_code(69)
      error_key(:cli_invalid_usage)
    end

    class NoSuchZone < RainError
      status_code(70)
      error_key(:nosuchzone)
    end

    class NoSuchVariable < RainError
      status_code(71)
      error_key(:no_such_variable)
    end

    class NoSuchUnAssocRelease < RainError
      status_code(72)
      error_key(:no_such_unassoc_release)
    end

    class SafetyCheckFailed < RainError
      status_code(73)
      error_key(:safety_check_failed)
    end

    class TemplateNotDefined < RainError
      status_code(74)
      error_key(:template_not_defined)
    end

    class TemplateNotFound < RainError
      status_code(75)
      error_key(:template_not_found)
    end

    class NoSuchProvider < RainError
      status_code(76)
      error_key(:no_such_provider)
    end



    class CLIInvalidOptions < RainError
      status_code(1)
      error_key(:cli_invalid_options)
    end

  end
end
