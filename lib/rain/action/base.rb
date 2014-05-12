

module Rain
  module Action

    class Base

      include Rain::Util::Logger

      def initialize(args, options = {})
        @args = args
        @options = options
      end

    end
  end
end