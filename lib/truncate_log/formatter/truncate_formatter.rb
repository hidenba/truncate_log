# frozen_string_literal: true

require 'logger'

module TruncateLog
  module Formatter
    class TruncateFormatter < Logger::Formatter
      attr_reader :original_formatter

      def initialize(original_formatter = nil)
        @original_formatter = original_formatter || Logger::Formatter.new
      end

      def call(severity, time, progname, msg)
        truncated_msg = TruncateLog::Truncator.truncate(msg)
        original_formatter.call(severity, time, progname, truncated_msg)
      end
    end
  end
end
