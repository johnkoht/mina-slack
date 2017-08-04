module Mina
  module Helpers
    module Output
      def print_line(line)
        line.scrub!
        case line
        when /^\-+> (.*?)$/
          print_status Regexp.last_match[1]
        when /^! (.*?)$/
          print_error Regexp.last_match[1]
        when /^\$ (.*?)$/
          print_command Regexp.last_match[1]
        else
          print_stdout line
        end
      end

      def print_status(msg)
        msg.scrub!
        puts "#{color('----->', 32)} #{msg}"
      end

      def print_error(msg)
        msg.scrub!
        puts " #{color('!', 33)}     #{color(msg, 31)}"
      end

      def print_stderr(msg)
        msg.scrub!
        if msg =~ /I, \[/ # fix for asset precompile
          print_stdout msg
        else
          puts "       #{color(msg, 31)}"
        end
      end

      def print_command(msg)
        msg.scrub!
        puts "       #{color('$', 36)} #{color(msg, 36)}"
      end

      def print_info(msg)
        msg.scrub!
        puts "       #{color(msg, 96)}"
      end

      def print_stdout(msg)
        msg.scrub!
        puts "       #{msg}"
      end

      def color(str, c)
        ENV['NO_COLOR'] ? str : "\033[#{c}m#{str}\033[0m"
      end
    end
  end
end

extend Mina::Helpers::Output
