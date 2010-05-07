require 'cxxproject'

describe Dependencies do
  it 'should build the right dependency-chain' do
    lib1 = SourceLibrary.new('1')
    lib2 = SourceLibrary.new('2').set_dependencies(['1'])
    lib3 = SourceLibrary.new('3').set_dependencies(['1'])
    lib4 = SourceLibrary.new('4').set_dependencies(['2', '3'])
    deps = Dependencies.transitive_dependencies(['4'])
    deps.map {|d|d.name}.should == ['4', '2', '3', '1']
  end
end
