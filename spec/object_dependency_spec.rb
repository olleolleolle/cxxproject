require 'spec_helper'
require 'cxxproject'
require 'cxxproject/ext/rake_listener.rb'
require 'cxxproject/utils/cleanup'

describe Rake::Task do
  compiler = 'gcc'
  before(:each) do
    Rake::application.options.silent = true
    Cxxproject::Utils.cleanup_rake
  end
  after(:each) do
    Cxxproject::Utils.cleanup_rake
  end

  it 'should fail if source of object is missing' do
    file 'test.cc' => 'compiler'
    File.delete('test.cc') if File.exists?('test.cc')
    sl = Cxxproject::SourceLibrary.new('testlib').set_sources(['test.cc']).set_project_dir(".")
    cxx = CxxProject2Rake.new([], 'build', compiler)

    task = Rake::application['lib:testlib']
    task.invoke
    task.failure.should eq(true)

    FileUtils.rm_rf('build')
  end

  it 'should not fail if include-dependency of object is missing' do
    File.open('test.cc', 'w') do |io|
      io.puts('#include "test.h"')
    end

    File.open('test.h', 'w') do |io|
    end

    sl = Cxxproject::SourceLibrary.new('testlib').set_sources(['test.cc']).set_project_dir(".")
    CxxProject2Rake.new([], 'build', compiler)

    task = Rake::application['lib:testlib']
    task.invoke
    task.failure.should == false

    Cxxproject::Utils.cleanup_rake

    FileUtils.rm_rf('test.h')
    File.open('test.cc', 'w') do |io|
    end

    sl = Cxxproject::SourceLibrary.new('testlib').set_sources(['test.cc']).set_project_dir(".")
    CxxProject2Rake.new([], 'build', compiler)

    task = Rake::application['build/libs/libtestlib.a']
    task.invoke
    task.failure.should == false

    FileUtils.rm_rf('test.cc')
  end

end
