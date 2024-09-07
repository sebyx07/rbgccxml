## What is rbgccxml?

RbGCCXML allows one to easily parse out and query C++ code. This library uses CastXML to parse out the C++ code into XML, and then nokogiri for parsing and querying.

CastXML (https://github.com/CastXML/CastXML) is an application that takes takes the parse tree of g++ and constructs a very parsable and queryable XML file with all related information. CastXML currently only works with code declarations; there currently are no plans to support code bodies.

Note: For those familiar with pygccxml, the similarities are minimal. Outside of the purpose
of both libraries, rbgccxml was built from scratch to provide a Ruby-esque query API instead of
being a port. However, many thanks to Roman for his work, without which this library would also
not exist.

## Requirements

* nokogiri
* castxml

## Installation

    gem install rbgccxml

RbGCCXML will work on all platforms that CastXML supports, which includes Windows, Mac, and *nix.

## The Project

RbGCCXML's source is in a git repository hosted on github:

Project page:

    http://github.com/jasonroelofs/rbgccxml

Clone with:

    git clone git://github.com/jasonroelofs/rbgccxml.git

## Usage

### Parsing

All rbgccxml parses start with the RbGCCXML.parse method:

```ruby
# Parse a single header file
RbGCCXML.parse("/path/to/header/file.h")

# Parse out all files that match a given glob
RbGCCXML.parse("/my/headers/**/*.h")

# Parse out a specified set of files"
RbGCCXML.parse(["/path/to/file1.h", "/path/to/file2.h", ...])

# Parse out multiple globs
RbGCCXML.parse(["/my/headers/**/*.h", "/other/headers/*.hpp"])
```

### Configuration

As CastXML runs on top of Clang, it will need to know about locations of other header files
that may be included by the header files being parsed out. Adding these paths is simple:

```ruby
RbGCCXML.parse(..., :includes => *directories)
```

where `directories` can be a single directory string or an array of directories, just like RbGCCXML.parse.

Also, if there are other CXXFLAGS that need to be added to the command line for CastXML to properly
parse the source headers (say, -D defines), add those via the :cxxflags option.

```ruby
RbGCCXML.parse(..., :cxxflags => *flags)
```

RbGCCXML tries to intelligently find the location of the `castxml` and `clang++` binaries, but if these binaries cannot be found, you can specify an exact path using the `:castxml_path` and `:clangpp_path` options respectively.

### Querying By Name

Once the header files have been parsed, RbGCCXML.parse returns a Namespace node that references the
global namespace "::". From here, all the function, class, etc declarations are easily queryable.

```ruby
source = RbGCCXML.parse('header.h')  #=> <Namespace ...>
```

Each major C++ node (class, struct, function, method, argument (of functions, methods,
and constructors)) have a related query method that can be called in various ways:

```ruby
# Get all classes in the current scope
source.classes

# Explicitly call #find on these classes
source.classes.find(...)

# Or use a short cut, if you're just looking for a class by a given name
source.classes("ClassName")

# Find supports regular expressions as well
source.classes(/Manager$/)
```

These queries are also nestable as long as there's more code available to query.
To find the class "Math" inside the namespace "core::utils", you can do:

```ruby
source.namespaces('core').namespaces('utils').classes('Math')
```

or in a short-hand / C++ qualified form:

```ruby
source.namespaces('core::utils').classes('Math')

# or
source.classes('core::utils::Math')
```

### Querying with #find

Of course, querying for names is only the tip of the powerful querying that RbGCCXML supports.

What if you want to find all methods on a class that return an int and have three arguments of
any type? This is easy with RbGCCXML:

```ruby
source.classes('TheClass').methods.find(returns: :int, arguments: [nil, nil, nil])
```

The keys `:returns` and `:arguments` can be used on their own or together as seen above.
The `:arguments` option must be an array, and if the type of the argument doesn't matter, placing
'nil' in it's place acts as a wildcard. `QueryResult#find` is also chainable, provided that there
are always more than one result. Otherwise, if there is just one result, only that Node will
be returned and any further chained `QueryResult#find` methods will fail with NoMethodError.

### The Next Step

See RbGCCXML::Node for all methods available on all C++ nodes.

See RbGCCXML::QueryResult for the full run-down on #find

## Additional Notes

Querying for unsigned types is currently not implemented.

