# frozen_string_literal: true

require 'semantic_logger'
require 'json'

module TruncateLog
  module Formatter
    module SemanticLogger
      class Truncate < ::SemanticLogger::Formatters::Json
        def call(log, logger)
          message = JSON.parse(super(log, logger))
          TruncateLog::Truncator.truncate(message).to_json
        end
      end
    end
  end
end
