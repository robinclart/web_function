# frozen_string_literal: true

module WebFunction
  class Documentation
    def initialize(package)
      @package = package
    end

    def generate
      buffer = ""

      buffer << @package.docs.strip
      buffer << "\n\n"
      @package.endpoints.each do |endpoint|
        arguments = endpoint.arguments
        buffer << endpoint.docs.strip
        buffer << "\n\n"
        buffer << "Signature:"
        buffer << "\n"
        buffer << "```"
        buffer << "\n"
        buffer << endpoint.name
        buffer << " { "
        buffer << arguments.map { |a| "#{a.name}: #{a.type}" }.join(", ")
        buffer << " } -> ("
        buffer << endpoint.returns.join(" | ")
        buffer << ")"
        buffer << "\n"
        buffer << "```"
        buffer << "\n\n"
        buffer << "Arguments:"
        buffer << "\n"
        arguments.each do |argument|
          buffer << "  - "
          buffer << "#{argument.name} (#{argument.type}): "
          if argument.flags.include?("required")
            buffer << "**Required.** "
          else
            buffer << "**Optional.** "
          end
          buffer << argument.docs.strip
          buffer << "\n"
        end
        buffer << "\n"
      end

      buffer
    end
  end
end
