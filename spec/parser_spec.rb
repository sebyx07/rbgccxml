# frozen_string_literal: true

describe 'Default parsing configuration' do
  specify 'can be given a raw XML file' do
    RbGCCXML.parse_xml(full_dir('parsed/Adder.xml'))
  end

  specify 'can parse a single header file' do
    RbGCCXML.parse(full_dir('headers/Adder.hpp'))
  end

  specify 'can parse a glob' do
    RbGCCXML.parse(full_dir('headers/*.hpp'))
  end

  specify 'can parse all files in a directory' do
    RbGCCXML.parse(full_dir('headers'),
                  includes: full_dir('headers/include'),
                  cxxflags: '-DMUST_BE_DEFINED')
  end

  specify 'can take an array of files' do
    files = [full_dir('headers/Adder.hpp'),
              full_dir('headers/Subtracter.hpp')]

    RbGCCXML.parse(files)
  end

  specify 'can take an array of globs' do
    files = [full_dir('headers/*.hpp')]

    RbGCCXML.parse(files, includes: full_dir('headers/include'))
  end

  specify "should throw an error if files aren't found" do
    lambda do
      RbGCCXML.parse(full_dir('headers/Broken.hcc'))
    end.should raise_error(RbGCCXML::SourceNotFoundError)

    lambda do
      RbGCCXML.parse(full_dir('hockers'))
    end.should raise_error(RbGCCXML::SourceNotFoundError)

    lambda do
      RbGCCXML.parse(full_dir('something/*'))
    end.should raise_error(RbGCCXML::SourceNotFoundError)

    lambda do
      RbGCCXML.parse([full_dir('something/*'), full_dir('anotherthing/*')])
    end.should raise_error(RbGCCXML::SourceNotFoundError)
  end
end

describe 'Configurable parsing configuration' do
  specify 'can give extra include directories for parsing' do
    found = RbGCCXML.parse full_dir('headers/with_includes.hpp'),
      includes: full_dir('headers/include')
    found.namespaces('code').should_not be_nil
  end

  specify 'can be given extra cxxflags for parsing' do
    RbGCCXML.parse full_dir('headers/requires_define.hxx'),
      cxxflags: '-DMUST_BE_DEFINED'
  end

  specify 'can give an explicit path to castxml' do
    lambda do
      RbGCCXML.parse full_dir('headers/requires_define.hxx'),
        castxml_path: '/not/here/castxml'
    end.should raise_error(RuntimeError, %r{/not/here/castxml})
  end

  specify 'can give an explicit path to clang++' do
    lambda do
      RbGCCXML.parse full_dir('headers/requires_define.hxx'),
        clangpp_path: '/not/here/clang++'
    end.should raise_error(RuntimeError, %r{/not/here/clang++})
  end
end
