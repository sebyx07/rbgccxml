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
      return false unless val =~ delim
      new_val = val.gsub(delim, "").strip
      XMLParsing.find_type_of(self.node, "type") == new_val
    end

    # Get the base type without any qualifiers. E.g, if you've
    # got the CvQualifiedType "const my_space::MyClass&, this 
    # will return the Node for "my_space::MyClass"
    #
    # returns: Node related to the base C++ construct of this type
    def base_type
      n = XMLParsing.find_type_of(self.node, "type")
      n.is_a?(Type) ? n.base_type : n
    end

    # Is this type const qualified?
    def const?
      found = XMLParsing.find_type_of(self.node, "type")
      found ? found.const? : false
    end

  end

end
