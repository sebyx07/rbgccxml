# frozen_string_literal: true

module RbGCCXML
  # The base class for all type management classes.
  # RbGCCXML has a pretty extensive type querying sub-system that
  # allows type matching by names, types, base types, etc
  class Type < Node
    # For types like pointers or references, we recursively track down
    # the base type when doing comparisons.
    #
    # delim needs to be a regex
    def check_sub_type_without(val, delim)
      if val.is_a?(String)
        return false unless val&.match?(delim)
        new_val = val.gsub(delim, '').strip
      elsif val.is_a?(RbGCCXML::PointerType)
        # Handle PointerType objects
        new_val = val.base_type
      else
        return false
      end

      base_type = NodeCache.find(attributes['type'])
      base_type == new_val
    end

    # Get the base type without any qualifiers. E.g, if you've
    # got the CvQualifiedType "const my_space::MyClass&, this
    # will return the Node for "my_space::MyClass"
    #
    # returns: Node related to the base C++ construct of this type
    def base_type
      n = NodeCache.find(attributes['type'])
      n.is_a?(Type) ? n.base_type : n
    end
    once :base_type

    # Is this type const qualified?
    def const?
      found = NodeCache.find(attributes['type'])
      found ? found.const? : false
    end
  end
end
