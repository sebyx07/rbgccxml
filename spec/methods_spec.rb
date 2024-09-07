# frozen_string_literal: true

describe 'Querying for class methods' do
  before(:all) do
    @adder_source = RbGCCXML.parse(full_dir('headers/Adder.hpp')).namespaces('classes')
  end

  specify 'should be able to get the methods on a class' do
    adder = @adder_source.classes.find(name: 'Adder')
    methods = adder.methods

    methods.size.should == 4
    found = methods.sort { |a, b| a.name <=> b.name }
    found[0].name.should == 'addFloats'
    found[1].name.should == 'addIntegers'
    found[2].name.should == 'addStrings'
    found[3].name.should == 'getClassName'
  end

  # The following are simplistic. functions_test tests the
  # finder options much more completely. This is just to test
  # that it works on Method objects fine
  specify 'should be able to get methods by name' do
    adder = @adder_source.classes('Adder')
    adder.methods('addIntegers').name.should == 'addIntegers'
    adder.methods.find(name: 'addStrings').name.should == 'addStrings'
  end

  specify 'can search methods via arguments' do
    adder = @adder_source.classes('Adder')
    adder.methods.find(arguments: [:int, :int]).name.should == 'addIntegers'
  end

  specify 'can search methods via return type' do
    adder = @adder_source.classes('Adder')
    adder.methods.find(returns: :float).name.should == 'addFloats'
  end

  specify 'can search via all options (AND)' do
    adder = @adder_source.classes('Adder')
    got = adder.methods.find(returns: :int, arguments: [nil, nil])
    got.name.should == 'addIntegers'
  end
end

describe 'Properties on Methods' do
  before(:all) do
    @classes_source = RbGCCXML.parse(full_dir('headers/classes.hpp')).namespaces('classes')
  end

  specify 'should be able to tell if a given method is static or not' do
    test1 = @classes_source.classes('Test1')
    test1.methods('staticMethod').should be_static

    test2 = @classes_source.classes.find(name: 'Test2')
    test2.methods('func1').should_not be_static
  end

  specify 'should be able to tell if a given method is virtual or not' do
    test4 = @classes_source.classes('Test4')
    test4.methods('func1').should be_virtual
    test4.methods('func1').should_not be_purely_virtual

    test4.methods('func2').should be_virtual
    test4.methods('func2').should_not be_purely_virtual

    test4.methods('func3').should be_virtual
    test4.methods('func3').should be_purely_virtual
  end
end
