# frozen_string_literal: true

require 'nokogiri'

module RbGCCXML
  # This class manages the parsing of the C++ code.
  # Please use RbGCCXML.parse and not this class directly
  class Parser
    def initialize(config = {})
      if config[:pregenerated]
        @xml_file = config.delete(:pregenerated)
      else
        @gccxml = GCCXML.new

        if includes = config.delete(:includes)
          @gccxml.add_include includes
        end

        if flags = config.delete(:cxxflags)
          @gccxml.add_cxxflags flags
        end

        if path = config.delete(:castxml_path)
          @gccxml.set_castxml_path path
        end

        if path = config.delete(:clangpp_path)
          @gccxml.set_clangpp_path path
        end

        validate_glob(config[:files])
      end
    end

    # Starts the parsing process. If the parser was configured
    # with one or more header files, this includes:
    # 1. Creating a temp file for the resulting XML.
    # 2. Finding all the files to run through CastXML
    # 3. If applicable (more than one header was specified),
    #    build another temp file and #include the header files
    #    to ensure one and only one pass into CastXML.
    # 4. Build up our :: Namespace node and pass that back
    #    to the user for querying.
    #
    # If the parser was configured for pregenerated CastXML
    # output, we only have to perform step 4 above.
    def parse
      if @gccxml
        require 'tempfile'
        @results_file = Tempfile.new('rbgccxml')
        parse_file = nil

        if @files.length == 1
          parse_file = @files[0]
        else
          # Otherwise we need to build up a single header file
          # that #include's all of the files in the list, and
          # parse that out instead
          parse_file = build_header_for(@files)
        end

        xml_file = @results_file.path
        @gccxml.parse(parse_file, xml_file)
      else
        xml_file = @xml_file
      end

      NodeCache.clear

      parser = SAXParser.new(xml_file)

      # Runs the SAX parser and returns the root level node
      # which will be the Namespace node for "::"
      parser.parse
    end

    private
      def build_header_for(files)
        header = Tempfile.new('header_wrapper')
        header.open

        @files.each do |file|
          header.write "#include \"#{file}\"\n"
        end

        header.close

        header.path
      end

      def validate_glob(files)
        found = []

        if files.is_a?(Array)
          files.each { |f| found << Dir[f] }
        elsif ::File.directory?(files)
          found = Dir[files + '/*']
        else
          found = Dir[files]
        end

        found.flatten!

        if found.empty?
          raise SourceNotFoundError.new(
            "Cannot find files matching #{files.inspect}. " +
            'You might need to specify a full path.')
        end

        @files = found.select { |f| !::File.directory?(f) }
      end
  end
end
