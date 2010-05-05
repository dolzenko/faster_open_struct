require 'rspec/core'
require 'rspec/expectations'
require 'rspec/matchers'
require 'ostruct'

share_examples_for "OpenStruct-like object" do
  describe "initialization from Hash" do
    describe "with symbol keys" do
      it "creates reader method" do
        @klass.new(:a => 42).a.should == 42
      end

      it "creates writer method" do
        @klass.new(:a => 42).tap { |fos| fos.a = "hi!" }.a.should == "hi!"
      end
    end

    describe "with string keys" do
      it "creates reader method" do
        @klass.new("a" => 42).a.should == 42
      end

      it "creates writer method" do
        @klass.new(:b => 1).tap { |fos| fos.a = "hi!" }.a.should == "hi!"
      end

      it "creates predicate method" do
        @klass.new(:a? => 1).a?.should == 1
      end
    end
  end

  describe "initialization with writers" do
    it "creates reader method when writer is called" do
      @klass.new.tap { |fos| fos.a = 42 }.a.should == 42
    end

    it "creates writer method when writer is called" do
      @klass.new.tap { |fos| fos.a = 42; fos.a = "hi!" }.a.should == "hi!"
    end
  end

  describe "comparison" do
    it "should compare like underlying initialization hashes" do
      @klass.new(:a => 42).should == @klass.new(:a => 42)
    end

    it "should compare like underlying created hashes" do
      @klass.new.tap { |fos| fos.a = 42 }.should == @klass.new.tap { |fos| fos.a = 42 }
    end

    it "should compare like underlying initialization altered hashes" do
      @klass.new(:a => 42).tap { |fos| fos.b = "hi!" }.should == @klass.new(:a => 42).tap { |fos| fos.b = "hi!" }
    end
  end

  describe "error reporting" do
    it "should report when too much writer arguments are supplied" do
      lambda { @klass.new.send(:a=, 1, 2) }.should raise_error(ArgumentError, /wrong number of arguments .2 for 1./)
    end
    
    it "should report when too little writer arguments are supplied" do
      lambda { @klass.new.send(:a=) }.should raise_error(ArgumentError, /wrong number of arguments .0 for 1./)
    end

    it "should report when non-writer method is called with arguments" do
      lambda { @klass.new.a(1) }.should raise_error(NoMethodError, /undefined method `a'/)
    end

    it "should raise exception when modifying frozen" do
      lambda { @klass.new.freeze.a = 1 }.should raise_error(TypeError, /can't modify frozen/)
    end
  end

  describe "marshaling" do
    it "should survive loading from marshaled state" do
      os = @klass.new(:a => 42).tap { |fos| fos.b = "hi!" }
      os.a
      survivor = Marshal.load(Marshal.dump(os))
      survivor.a.should == 42
      survivor.b.should == "hi!"
    end
  end
  
  describe "#inspect" do
    it "works" do
      @klass.new(:a => 42).tap { |fos| fos.b = "hi!" }.inspect.should match(%r{^#<.*OpenStruct a=42, b="hi!">$})
    end

    it "handles self-recursive cases" do
      os = @klass.new
      os.a = os
      os.inspect.should match(%r{^#<(Faster::|)OpenStruct a=#<(Faster::|)OpenStruct \.\.\.>>$}x)
    end

    it "handles deep self-recursive cases" do
      os = @klass.new
      os.a = @klass.new
      os.a.a = os
      os.inspect.should match(%r{^#<(Faster::|)OpenStruct a=#<(Faster::|)OpenStruct \.\.\.>>\z}x)
    end
  end
end

describe "Faster::OpenStruct" do
  before(:each) do
    Faster.send(:remove_const, :OpenStruct) if defined?(Faster::OpenStruct)
    load "./faster_open_struct.rb"
    @klass = Faster::OpenStruct
    
    if Faster::OpenStruct.method_defined?(:a) ||
            Faster::OpenStruct.method_defined?(:b) ||
            Faster::OpenStruct.method_defined?(:a?)
      raise "reloading hack failed, clean test state is not guaranteed"
    end
  end

  it_should_behave_like "OpenStruct-like object"

  it "reponds to empty? to work seamlessly with ActiveSupport" do
    @klass.new.empty?.should == true
    @klass.new(:a => 1).empty?.should == false
    @klass.new.tap { |os| os.a = 1 }.empty?.should == false
  end

  it "undefines commonly interfering methods" do
    @klass.new.type == nil
    @klass.new.id == nil
  end

  if GC.respond_to?(:enable_stats) && !ENV["SKIP_PERFORMANCE"]
    describe "performance gains" do
      def allocated_by_block(allocations = 10_000)
        GC.clear_stats
        GC.disable_stats
        GC.start
        GC.enable_stats
        before = GC.allocated_size
        eater = []
        allocations.times { eater << yield }
        GC.allocated_size - before
      end

      it "should take 40 times less memory compared to OpenStruct" do
        open_struct = allocated_by_block { OpenStruct.new({ :a => 1 }) }
        faster_open_struct = allocated_by_block { Faster::OpenStruct.new({ :a => 1 }) }
        (open_struct.to_f / faster_open_struct).should > 40
      end
    end
  else
    it "Use REE to test permormance gains"
  end
end

describe OpenStruct do
  before(:each) do
    @klass = OpenStruct
  end
  it_should_behave_like "OpenStruct-like object"
end
