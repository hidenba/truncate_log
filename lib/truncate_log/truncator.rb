# frozen_string_literal: true

require 'json'

module TruncateLog
  class Truncator
    @config = TruncateLog::Config.new

    class << self
      attr_reader :config

      def configure
        yield config if block_given?
      end

      def truncate(data, current_depth = 0, max_depth = config.max_depth, threshold_multiplier = 1)
        return data unless data.is_a?(Hash) || data.is_a?(Array) || data.is_a?(String)

        return data if data_size(data) <= config.max_item_size || threshold_multiplier <= 0.1

        truncated = case data
                    when String
                      max_length = config.max_string_length * threshold_multiplier
                      "#{data[0..max_length]}... (#{data.bytesize - max_length} more bytes omitted)"
                    when Array
                      truncate_array(data, current_depth, max_depth, threshold_multiplier)
                    when Hash
                      truncate_hash(data, current_depth, max_depth, threshold_multiplier)
                    end
        truncate(truncated, current_depth, max_depth, threshold_multiplier * 0.5)
      rescue StandardError
        data
      end

      private

      def truncate_array(array, current_depth, max_depth, threshold_multiplier)
        if current_depth >= max_depth * threshold_multiplier
          return ["Array too large, omitted (#{array.size} elements)"]
        end

        max_size = config.max_array_items * threshold_multiplier
        if array.size > max_size
          truncated = array[0..max_size].map do |item|
            truncate(item, current_depth + 1, max_depth, threshold_multiplier)
          end
          truncated << "... (#{array.size - max_size} more elements omitted)"

          return truncated
        end

        array.map { |item| truncate(item, current_depth + 1, max_depth, threshold_multiplier) }
      end

      def truncate_hash(hash, current_depth, max_depth, threshold_multiplier)
        if current_depth >= max_depth * threshold_multiplier
          return { summary: "Hash too large, omitted (#{hash.keys.size} keys)" }
        end

        hash.transform_values do |value|
          if data_size(value) > config.max_item_size * threshold_multiplier
            truncate(value, current_depth + 1, max_depth, threshold_multiplier)
          else
            value
          end
        end
      end

      def data_size(data)
        json_data = ::JSON.generate(data)
        json_data.bytesize
      end
    end
  end
end
