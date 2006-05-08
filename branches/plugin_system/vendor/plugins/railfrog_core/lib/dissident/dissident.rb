#
# Dissident -- a Ruby dependency injection container
#
# Copyright (C) 2005  Christian Neukirchen <chneukirchen@gmail.com>
#
# This work is licensed under the same terms as Ruby itself.
#

module Dissident
  VERSION = "0.2"
end

# Dissident adds a few helper methods to Class.
class Class
  alias :__new_dissident__ :new

  # Register the class in Dissident and replace the instantiation
  # method +new+ with magic to automatically inject the dependencies.
  def use_dissident!
    klass = self
    unless Dissident::INJECTED.include? klass
      Dissident::INJECTED[klass] = false
      (class << self; self; end).module_eval {
        define_method(:new) { |*args|
          constructor_parameters = Dissident.constructor_parameters klass
          object = __new_dissident__(*(constructor_parameters + args))
          Dissident.inject object
          object
        }
      }
    end
  end

  # Declare _names_ to be dependencies of this class that should be
  # injected at instantiation.
  def inject(*names)
    use_dissident!
    # Mark for container injection.
    Dissident::INJECTED[self] = true
    names.each { |name|
      define_method(name) { |*args|
        @__dissident__.fetch name, *args
      }
    }
  end

  # Declare this class to belong to the library _lib_ (which is usually
  # the namespace module of the library, or the core class).
  def library(lib)
    Dissident::LIBRARIES[self] = lib
  end

  # Declare _default_ (a Dissident::Container) to be used as container
  # if none was declared dynamically.  Only works with a proper +library+
  # declaration for the class.
  #
  # The global default container can be set with
  # <code>Dissident.container=</code>.
  def default_container(default)
    lib = Dissident::LIBRARIES[self]
    if lib.nil?
      raise ArgumentError, "trying to set global default container inside class"
    end
    Thread.main[:DISSIDENT_CONTAINER][lib] = Dissident.instantiate default
  end
end

module Dissident
  # A hash containing classes to inject in as keys.
  INJECTED = {}

  # A hash mapping classes to the libraries they belong to.
  LIBRARIES = {}

  # This exception is thrown if a service can not be looked up or was
  # not defined.
  class MissingServiceError < RuntimeError; end

  class << self
    # Set the global default container to _default_.  Usually not needed,
    # it is better style to use Dissident.with.
    def container=(default)
      Thread.main[:DISSIDENT_CONTAINER][nil] = if default.nil?
                                                 nil
                                               else
                                                 Dissident.instantiate default
                                               end
    end

    # Instantiate +object+ (a Dissident::Container) to be used for
    # dependency injection.
    def instantiate(object)
      if object.kind_of? Class and object < Container
        cont = object.new
        cache = Cache.new(cont)
        cont.cache = cache
      else
        raise ArgumentError, "#{object} is not a Dissident::Container"
      end
    end

    # Make _cont_ the current global container in _block_.
    #
    # Optionally, pass a hash that maps libraries to the container
    # used for them.  Example:
    #
    #   Dissident.with MyGlobalContainer,
    #                  MyFirstLib => FirstContainer,
    #                  MySecondLib => SecondContainer do
    #     ...
    #   end
    def with(cont, library = nil, &block)
      if cont.kind_of? Hash or library.kind_of? Hash
        if library.nil?
          recurse cont, &block
        else
          with(cont) { recurse library, &block }
        end
      else
        if block.nil?
          raise ArgumentError, "Dissident.with must be called with a block"
        end

        cont = instantiate cont
        
        fluid_let(library, cont) {
          yield cont
        }
      end
    end

    # Register _klass_ to make use of Dissident.
    #
    # This needs only to be explicitly called when you declare
    # Constructor Injection with +DISSIDENT_CONSTRUCTOR+.
    #
    # It is recommended to make use of +provide+ instead of this.
    def use_for(klass)
      klass.use_dissident!
    end

    # Inject all the dependencies of _object_.
    def inject(object)
      if object.class.ancestors.any? { |a| INJECTED[a] }
        container = container_for object.class
        
        if container.nil?
          warn "Dissident: Cannot inject to #{object} " <<
            "(#{library(object.class) || "default application"}), " <<
            "no container given."
        else
          object.instance_variable_set :@__dissident__, container
        end
      end
      object
    end

    # Return the declared dependencies of _klass_ that are to
    # be injected using Constructor Injection.
    def constructor_parameters(klass)
      if klass.const_defined? :DISSIDENT_CONSTRUCTOR
        container = container_for klass
        klass.const_get(:DISSIDENT_CONSTRUCTOR).map { |service|
          container.fetch service
        }
      else
        # By default, inject no constructor parameters.
        []
      end
    end

    # Return the container that will be used for injecting
    # dependencies into objects of _klass_.
    def container_for(klass)
      copy_binding
      Thread.current[:DISSIDENT_CONTAINER].fetch(library(klass))
    end

  private

    def library(klass)
      LIBRARIES.fetch(klass) {
        if klass.superclass
          library klass.superclass
        end
      }
    end
        
    def recurse(rest, &block)
      library = rest.keys.first
      cont = rest.delete library
      
      # Zip down recursively.
      if rest.empty?
        with(cont, library, &block)
      else
        with(cont, library) {
          with rest, &block
        }
      end
    end

    def fluid_let(library, value, &block)
      copy_binding

      old_value = Thread.current[:DISSIDENT_CONTAINER][library]
      Thread.current[:DISSIDENT_CONTAINER][library] = value
      
      begin
        block.call
      ensure
        Thread.current[:DISSIDENT_CONTAINER][library] = old_value
      end
    end

    def copy_binding
      unless Thread.current.key? :DISSIDENT_CONTAINER
        Thread.current[:DISSIDENT_CONTAINER] =
          Thread.main[:DISSIDENT_CONTAINER].dup
      end
    end
  end

  # A subclass of Proc that will be evaluated automatically on each
  # injection.
  class Prototype < Proc
  end

  # Dissident::Cache keeps track of instantiated services by
  # implementing a multiton instantiation scheme.
  class Cache
    # Create a new Cache for the container _container_.
    def initialize(container)
      @container = container
      @values = {}
    end
    
    # Instantiate the service _name_ with the optional arguments
    # _args_.  Services that are of class Prototype will be evaluated
    # on each request.
    def fetch(name, *args)
      @values.fetch(name) {
        @values[name] = {}
      }.fetch(args) {
        unless @container.respond_to? name
          raise MissingServiceError,
            "no service `#{name}' defined in #@container"
        end
        
        service = @container.__send__(name, *args)
        unless service.kind_of? Prototype
          @values[name][args] = service
        else
          service.call            # Evaluate the prototype, don't cache.
        end
      }
    end
    alias_method :[], :fetch
    alias_method :method_missing, :fetch
    
    def respond_to?(name)
      super or @container.respond_to? name
    end
    
    # Don't clutter up #inspects.
    alias_method :inspect, :to_s
  end
  
  # Dissident::Container is the superclass of all Dissident containers.
  # It provides useful helpers for defining containers and implementing
  # multi-method dispatch.
  class Container
    class << self
      # Define _name_ to be the service returned by calling _block_.
      def define(name, &block)
        define_method name, &block
      end
      
      # Define _name_ to be the service that instantiates _klass_,
      # optionally passing _services_ as arguments to
      # _klass_<code>.new</code>.
      def provide(name, klass, *services)
        unless klass.kind_of? Class
          raise ArgumentError, "can only provide Classes"
        end
        
        define_method name.to_sym do |*args|
          klass.new(*(services.map { |service| container.fetch service } + args))
        end
      end
      
      # Define _name_ to be a service that always returns _value_.
      def constant(name, value)
        define_method name.to_sym do
          value
        end
      end
      
      # Define _name_ to be the service returned by calling _block_
      # when the arguments of the service match against _spec_.
      #
      # Arguments are matched with <code>===</code>, for example:
      #
      #    multimethod :mmd, Object, Object do |a, b|
      #     [a, b]
      #    end
      #    multimethod :mmd, Integer do |a|
      #      2 * a
      #    end
      #    multimethod :mmd, Integer, Integer do |a, b|
      #      a + b
      #    end
      #    multimethod :mmd, 2, 2 do |a, b|
      #      22
      #    end
      #
      #    mmd(1, 2)  #=> 3
      #    mmd(3, 3)  #=> 3
      #    mmd(2, 2)  #=> 22
      #    mmd("foo", "bar")  #=> ["foo", "bar"]
      #    mmd(22)    #=> 44
      #    mmd(1, 2, 3)  #~> NoMethodError
      def multimethod(name, *spec, &block)
        @@__dissident_mmd__ ||= {}
        (@@__dissident_mmd__[name] ||= []).unshift [spec, block]
        define_method name do |*args|
          _, mm = @@__dissident_mmd__[name].find { |(spec, block)|
            if spec.size == args.size
              spec.each_with_index { |s, i|
                break false  unless s === args[i]
              }
            else
              false
            end
          }
          
          if mm.nil?
            raise NoMethodError,
            "undefined method `#{name}' for parameters #{args.inspect}"
          end
          mm.call(*args)
        end
      end
    end

    # The cache to keep track of instantiated objects.
    attr_accessor :cache

    # Return the current cache used for keeping track of instantiated
    # objects.  You need to make use of this method when you need
    # to instantiate services that need other services.
    #
    # Example (better done using +provide+):
    #
    #   class MyContainer < Dissident::Container
    #     def service
    #       Service.new
    #     def
    #     
    #     def other_service
    #       # OtherService.new(service)    # wrong!
    #       OtherService.new(container.service)    # correct
    #     end
    #   end
    def container
      cache or raise RuntimeError, "no container known."
    end

    def fetch(*args)
      container.fetch(*args)
    end
    
    # Return a prototype that will evaluate _block_ on each
    # instantiation.
    def prototype(&block)
      if block.nil?
        raise ArgumentError, "prototype needs a block to evaluate each time"
      end
      Prototype.new(&block)
    end
  end
end

# Introduce main container.
Thread.main[:DISSIDENT_CONTAINER] = {nil => nil}
