# frozen_string_literal: true

module RbGCCXML
  # Represents a single <Argument> node.
  # Can be an argument for a Method, Function, or Constructor
  class Argument < Node
    # Get the Node for this argument's type
    def cpp_type
      type = NodeCache.find(attributes['type'])
      type.container = self
      type
    end

    # Get any default value for this argument
    def value
      self['default']
    end

    # See Node#to_cpp, prints out C++ code for this argument
    def to_cpp(qualified = true)
      "#{self.cpp_type.to_cpp(qualified)} #{self.name}"
    end
    once :to_cpp
  end
end
