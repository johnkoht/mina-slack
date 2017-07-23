module Mina
  module Helpers
    module Output
      def print_line(line)
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
      rescue Encoding::InvalidByteSequenceError
        puts 'Invalid byte sequence'
      end

      def print_status(msg)
        puts "#{color('----->', 32)} #{msg}"
      rescue Encoding::InvalidByteSequenceError
        puts 'Invalid byte sequence'
      end

      def print_error(msg)
        puts " #{color('!', 33)}     #{color(msg, 31)}"
      rescue Encoding::InvalidByteSequenceError
        puts 'Invalid byte sequence'
      end

      def print_stderr(msg)
        if msg =~ /I, \[/ # fix for asset precompile
          print_stdout msg
        else
          puts "       #{color(msg, 31)}"
        end
      rescue Encoding::InvalidByteSequenceError
        puts 'Invalid byte sequence'
      end

      def print_command(msg)
        puts "       #{color('$', 36)} #{color(msg, 36)}"
      rescue Encoding::InvalidByteSequenceError
        puts 'Invalid byte sequence'
      end

      def print_info(msg)
        puts "       #{color(msg, 96)}"
      rescue Encoding::InvalidByteSequenceError
        puts 'Invalid byte sequence'
      end

      def print_stdout(msg)
        puts "       #{msg}"
      rescue Encoding::InvalidByteSequenceError
        puts 'Invalid byte sequence'
      end

      def color(str, c)
        ENV['NO_COLOR'] ? str : "\033[#{c}m#{str}\033[0m"
      end
    end
  end
end

extend Mina::Helpers::Output