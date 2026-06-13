# frozen_string_literal: true

module WebFunction
  # Internal utility methods.
  #
  # @api private
  #
  module Utils
    module_function

    # Normalizes a collection. Yields each item to the block if a block is given, otherwise returns the item.
    # Any `nil` items are removed.
    #
    # @param collection [Array] The collection to normalize
    #
    # @return [Array] The normalized array
    #
    def normalize_array(collection)
      unless collection.is_a?(Array)
        return []
      end

      items = collection.map do |item|
        if block_given?
          yield item
        else
          item
        end
      end

      items.compact
    end

    # Normalizes an array of strings. Uses #normalize_array under the hood.
    #
    # @param collection [Array] The collection to normalize
    #
    # @return [Array] The normalized array
    #
    def normalize_array_of_strings(collection)
      normalize_array(collection) { |item| item.to_s }
    end
  end
end
