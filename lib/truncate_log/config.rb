# frozen_string_literal: true

module TruncateLog
  class Config
    attr_accessor :max_item_size, :max_string_length, :max_array_items, :max_hash_keys, :max_depth

    def initialize
      @max_item_size = 1024
      @max_string_length = 512
      @max_array_items = 5
      @max_depth = 5
      @max_hash_keys = 10
    end
  end
end
