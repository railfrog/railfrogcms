require 'test/unit'
require 'dissident'

# forward declarations
class TestLibrary; end
class TestLibraryHelper; end
class TestConstructorHelper; end
class Foo; end

class TestRegistry < Dissident::Container
  def one; 1; end
  define(:two) { 2 }

  def array; [1, 2, 3]; end
  def arraync; prototype { [1, 2, 3] }; end

  def sng; Object.new; end

  def add_three(x, y, z)
    [x+y+z]
  end

  def thr(args, thread=Thread.current)
    [:thr, args]
  end

  multimethod :mmd, Object, Object do |a, b|
    [a, b]
  end
  multimethod :mmd, Integer do |a|
    2 * a
  end
  multimethod :mmd, Integer, Integer do |a, b|
    a + b
  end
  multimethod :mmd, 2, 2 do |a, b|
    22
  end

  provide :lib, TestLibrary
  provide :libhelper, TestLibraryHelper

  def subinstance
    container.sng
  end

  def subinstance2
    fetch(:sng)
  end

  def bad_subinstance
    sng
  end
 
  provide :constructorhelper, TestConstructorHelper, :one, :two

  constant :beast, 666
end

class TestDoubleRegistry < TestRegistry
  def one; 2; end
  def two; 4; end

  def array; [2, 4, 6]; end
end

class TestLibrary
  library TestLibrary
  default_container TestRegistry
  inject :one, :two
  inject :libhelper
end

class TestLibraryHelper
  library TestLibrary
  inject :one, :two
end

class TestHelper
  inject :one, :two
  inject :array
  inject :sng
  inject :thr
  inject :mmd
  inject :subinstance, :subinstance2, :bad_subinstance
  inject :beast

  inject :add_three, :lib, :libhelper
end

class TestInheritanceHelper < TestHelper
end

class TestInheritanceHelper2 < TestHelper
  inject :beast
end

class TestConstructorHelper
  attr_accessor :one, :two, :value
  def initialize(one, two, value=nil)
    @one = one
    @two = two
    @value = value
  end
end

class TestAutomaticConstructorHelper < TestConstructorHelper
  DISSIDENT_CONSTRUCTOR = [:one, :two]
end

class DissidentTest < Test::Unit::TestCase
  def silent(&block)
    old, $-w = $-w, nil
    block.call
  ensure
    $-w = old
  end

  def test_inject
    t = silent { TestHelper.new }          # warns
    assert_raise(NoMethodError) { t.one }
    assert_raise(NoMethodError) { t.two }

    Dissident.with TestRegistry do
      t2 = TestHelper.new
      assert_equal 1, t2.one
      assert_equal 2, t2.two
    end
  end

  def test_injection_cache
    Dissident.with TestRegistry do
      t1 = TestHelper.new
      i = t1.array.object_id
      assert_equal i, t1.array.object_id
      assert_equal i, t1.array.object_id
      assert_equal i, t1.array.object_id

      t2 = TestHelper.new
      assert_same t1.array, t2.array
      assert_same t1.array, t2.array
      assert_same t1.array, t2.array

      assert_same t1.lib, t2.lib
      assert_same t1.lib, t2.lib

      assert_same t1.subinstance, t1.sng
      assert_same t1.subinstance, t2.sng

      assert_same t1.subinstance2, t1.sng
      assert_same t1.subinstance2, t2.sng

      assert_not_same t1.bad_subinstance, t1.sng
      assert_not_same t1.bad_subinstance, t2.sng
    end
  end

  def test_singleton
    Dissident.with TestRegistry do
      t1 = TestHelper.new
      t2 = TestHelper.new
      t3 = TestHelper.new

      sng = t1.sng
      assert_same sng, t2.sng
      assert_same t1.sng, t2.sng
      assert_same sng, t3.sng
      assert_same t1.sng, t3.sng
    end
  end

  def test_multiton
    Dissident.with TestRegistry do
      a = TestHelper.new
      b = TestHelper.new

      result = a.add_three(1, 2, 3)

      assert_same result, a.add_three(1, 2, 3)
      assert_same result, a.add_three(1, 2, 3)
      assert_not_equal result, a.add_three(1, 2, 4)

      assert_same result, b.add_three(1, 2, 3)
      assert_same result, b.add_three(1, 2, 3)
      assert_not_equal result, b.add_three(1, 1, 1)
    end
  end

  def test_nesting
    t1 = t2 = t3 = t4 = t5 = nil

    Dissident.with TestRegistry do
      t1 = TestHelper.new
      assert_equal 1, t1.one
      assert_equal 2, t1.two

      Dissident.with TestDoubleRegistry do
        t2 = TestHelper.new
        assert_equal 2, t2.one
        assert_equal 4, t2.two

        Dissident.with TestRegistry do
          t3 = TestHelper.new
          assert_equal 1, t3.one
          assert_equal 2, t3.two
        end

        t4 = TestHelper.new
        assert_equal 2, t4.one
        assert_equal 4, t4.two
      end

      t5 = TestHelper.new
      assert_equal 1, t5.one
      assert_equal 2, t5.two

      assert_equal 1, t1.one
      assert_equal 2, t1.two
      assert_equal 2, t2.one
      assert_equal 4, t2.two
      assert_equal 1, t3.one
      assert_equal 2, t3.two
      assert_equal 2, t4.one
      assert_equal 4, t4.two
      assert_equal 1, t5.one
      assert_equal 2, t5.two
    end
  end

  def test_rescue
    Dissident.with TestRegistry do
      begin
        t1 = TestHelper.new
        assert_equal 1, t1.one
        assert_equal 2, t1.two
        
        Dissident.with TestDoubleRegistry do
          t2 = TestHelper.new
          assert_equal 2, t2.one
          assert_equal 4, t2.two

          raise "and out"
        end
      rescue
        t3 = TestHelper.new
        assert_equal 1, t3.one
        assert_equal 2, t3.two
      end
    end

    Dissident.with TestRegistry do
      catch(:out) {
        t1 = TestHelper.new
        assert_equal 1, t1.one
        assert_equal 2, t1.two
        
        Dissident.with TestDoubleRegistry do
          t2 = TestHelper.new
          assert_equal 2, t2.one
          assert_equal 4, t2.two

          throw :out
        end
      }
      t3 = TestHelper.new
      assert_equal 1, t3.one
      assert_equal 2, t3.two
    end
  end

  def test_libraries
    Dissident.with TestRegistry do
      t = silent { TestHelper.new }    # warns
      assert_equal 1, t.lib.one
      assert_equal 1, t.lib.libhelper.one
    end

    Dissident.with TestRegistry, TestLibrary => TestDoubleRegistry do
      t1 = TestHelper.new
      assert_equal 2, t1.lib.one
      assert_equal 2, t1.lib.libhelper.one
      
      Dissident.with nil => TestDoubleRegistry,
                     TestLibrary => TestRegistry do
        t2 = TestHelper.new
        assert_equal 1, t2.lib.one
        assert_equal 1, t2.lib.libhelper.one

        assert_equal 2, t2.one
        assert_equal 4, t2.two
      end
    end
  end

  def test_threading
    threads = [
      Thread.new {
        Dissident.with TestRegistry do
          t1 = TestHelper.new
          assert_equal 1, t1.one
          assert_equal 2, t1.two
        end
      },
      Thread.new {
        Dissident.with TestDoubleRegistry do
          t1 = TestHelper.new
          assert_equal 2, t1.one
          assert_equal 4, t1.two
        end
      }
    ].each { |t| t.join }
  end

  def test_threaded
    o1 = o2 = o3 = o4 = o5 = o6 = o7 = o8 = nil
    threads = [
      Thread.new {
        Dissident.with TestRegistry do
          t1 = TestHelper.new
          o1 = t1.thr []
          o2 = t1.thr []
          o3 = t1.thr [1, 2]
          o4 = t1.thr [1, 2]
        end
      },
      Thread.new {
        Dissident.with TestDoubleRegistry do
          t2 = TestHelper.new
          o5 = t2.thr []
          o6 = t2.thr []
          o7 = t2.thr [1, 2]
          o8 = t2.thr [1, 2]
        end
      }
    ].each { |t| t.join }
    assert_same o1, o2
    assert_same o3, o4
    assert_same o5, o6
    assert_same o7, o8
    assert_not_same o1, o3
    assert_not_same o1, o5
    assert_not_same o3, o7
    assert_not_same o4, o8
  end

  def test_multimethod
    Dissident.with TestRegistry do
      t = TestHelper.new
      assert_equal 3, t.mmd(1, 2)
      assert_equal 6, t.mmd(3, 3)
      assert_equal 22, t.mmd(2, 2)
      assert_equal ["foo", "bar"], t.mmd("foo", "bar")
      assert_equal 4, t.mmd(2)
      assert_equal 44, t.mmd(22)
      assert_raise(NoMethodError) { t.mmd(1, 2, 3) }
      assert_raise(NoMethodError) { t.mmd("foo") }
    end
  end

  def test_provide
    Dissident.with TestRegistry do
      t = TestHelper.new
      assert_kind_of TestLibrary, t.lib
      assert_same t.lib, t.lib

      assert_kind_of TestLibraryHelper, t.libhelper
      assert_same t.libhelper, t.libhelper

      assert_raise ArgumentError do
        Class.new(Dissident::Container) {
          provide :foo, 1
        }
      end
    end
  end

  def test_automatic_constructor_injection
    Dissident.use_for TestAutomaticConstructorHelper

    Dissident.with TestRegistry do
      t = TestAutomaticConstructorHelper.new
      assert_equal 1, t.one
      assert_equal 2, t.two

      # Make sure no container was injected.
      assert_equal false, t.instance_variables.include?("@__dissident__")
    end
  end

  def test_declared_constructor_injection
    Dissident.with TestDoubleRegistry do |registry|
      t = registry.constructorhelper
      assert_equal 2, t.one
      assert_equal 4, t.two

      t = registry.constructorhelper(:quux)
      assert_equal t.value, :quux
    end
  end

  def test_container_methods
    Dissident.with TestRegistry do |container|
      assert_equal 1, container.one
      assert_equal 2, container.two

      assert container.respond_to?(:one)
      assert container.respond_to?(:two)

      assert_same container.sng, container.sng
    end
  end

  def test_undefined_services
    Dissident.with TestRegistry do |registry|
      assert_raise(Dissident::MissingServiceError) { registry.thisdoesnotexist }
      assert_raise(Dissident::MissingServiceError) { registry[:neitheristhis] }
    end
  end

  def test_default_container
    assert_nothing_raised {
      Class.new {
        library Foo
        default_container TestRegistry
      }
    }

    assert_raise(ArgumentError) {
      Class.new { default_container TestRegistry }
    }

    Dissident.container = TestRegistry
    t2 = TestHelper.new
    assert_equal 1, t2.one
    assert_equal 2, t2.two
    Dissident.container = nil
  end

  def test_various_exceptions
    assert_raise(ArgumentError) {
      Dissident.with Foo do
      end
    }

    assert_raise(ArgumentError) { Dissident.with TestRegistry }
    assert_raise(RuntimeError) { TestRegistry.new.subinstance }
    assert_raise(RuntimeError) { TestRegistry.new.subinstance2 }
  end

  def test_constant
    Dissident.with TestRegistry do |r|
      assert_equal 666, r.beast
    end
  end

  def test_prototype
    Dissident.with TestRegistry do |r|
      a = r.arraync
      assert_not_same a, r.arraync
      assert_not_same a, r.arraync
    end

    assert_raise(ArgumentError) {
      Class.new(Dissident::Container) {
        def foo
          prototype
        end
      }.new.foo
    }
  end

  def test_inheritance
    Dissident.with TestRegistry do
      assert_kind_of TestHelper, TestHelper.new
      assert_kind_of TestInheritanceHelper, TestInheritanceHelper.new
      assert_kind_of TestInheritanceHelper2, TestInheritanceHelper2.new
      assert_equal TestHelper.new.instance_variable_get(:@__dissident__),
                   TestInheritanceHelper.new.instance_variable_get(:@__dissident__)
      assert_equal TestHelper.new.instance_variable_get(:@__dissident__),
                   TestInheritanceHelper2.new.instance_variable_get(:@__dissident__)
    end
  end
end
