require 'rain/errors'

module Rain
  class Main
    include Rain::Util::Logger

    def initialize(argv, stdin=STDIN, stdout=STDOUT, stderr=STDERR, kernel=Kernel)
      @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
      $stdin, $stdout, $stderr = stdin, stdout, stderr
    end

    def execute!

      begin
        retcode = 0
        Rain::Config.set_base_directory(__FILE__)
        Rain::Util::RainLogger.setup({:debug => true}) if ENV['RAIN_DEBUG']
        Rain::Command::Base.run(@argv)
      rescue Rain::Errors::HelpText => e
        puts e.message
      rescue Rain::Errors::RainError => e
        $stderr.puts "Rain experienced an error! Details:"
        debug { e.inspect }
        #debug { e.message }
        puts e.message
        debug { e.backtrace.join("\n") }
        retcode = e.respond_to?(:status_code) ? e.status_code : 999

      rescue Exception => e
        $stderr.puts "Rain generated an untrapped exception:\n\n"
        $stderr.puts e.message
        $stderr.puts e.backtrace
        retcode = 998
      ensure
        $stdin, $stdout, $stderr = STDIN, STDOUT, STDERR
      end

      @kernel.exit retcode
    end

  end
end
