# This extension to the Object class allows you to create extensions for
# a given extension point. Extensions are defined at class-level and
# executed in the scope of the instance. Therefore you can access instance
# variables from a class within an extension and verse visa (see example).
#
# Example:
# ========
#
# class Example
#   def foobar1
#     @a = 3
#     invoke_extensions :some_ext_point
#     @b += 10
#   end
#
#   def foobar2
#     @a = 3
#     all_extensions = get_extensions :some_ext_point
#     all_extensions.each { |extension| invoke_extension(extension) }
#     @b += 10
#   end
#
#   def foobar3
#     each_extension :another_ext_point, 3 do
#       puts @d
#     end
#   end
#
#   def_extension :some_ext_point do
#     puts "Hello "
#     @a += 5
#     @b = 2
#   end
#
#   def_extension :some_ext_point do
#     puts "World!"
#     @b -= 3
#   end
#
#   def_extension :another_ext_point do |d|
#     @d = d+1
#   end
#
#   def_extension :another_ext_point do
#     @d += 3
#   end
# end
#
# Result:
# - foobar1 = foobar2: 
#      "Hello World!"
#      @a = 8
#      @b = 9
# - foobar3: 
#      "4"
#      "7"

class Object
  @@__old_id__ = nil

  # This method lets you define an extension to a given extension point
  def def_extension(extension_point, &block)
    @@__extension_points__ = Hash.new unless @@__old_id__ == self.id
    (@@__extension_points__[extension_point] ||= []) << block
    @@__old_id__ = self.id
  end
  
  # Get an array of all extensions to a given extension point
  # (array of procs)
  def get_extensions(extension_point)
    @@__extension_points__[extension_point]
  end

  # Invoke all extensions to a given extension point
  def invoke_extensions(extension_point, *args)
    get_extensions(extension_point).map do |extension| 
      instance_call(*args, &extension)
    end
  end
  
  # Invoke a single extension. Parameter extension is a proc i.e. from
  # get_extensions
  def invoke_extension(extension, *args)
    instance_call(*args, &extension)
  end
  
  # Iterate over all extensions to an extension point.
  # 1) Invokes extensions
  # 2) Yield block in each_extension
  def each_extension(extension_point, *args, &block)
    get_extensions(extension_point).map do |extension|
      yield instance_call(*args, &extension)
    end
  end
  
  # See Ruby mailing-list (forgot where)
  def instance_call(*args, &block)
    result = nil
    klass = Class === self ? self : self::class
    m = "____evaluate____#{ Thread::current.object_id }____#{ rand 666 }____#{ rand 42 }____"
    klass.module_eval { define_method m, &block }
    begin
      result = send(m, *args)
    ensure
      klass.module_eval { remove_method m } rescue nil
    end
    result
  end
end