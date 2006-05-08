
require 'dissident'
require 'yaml'

class Registry < Dissident::Container
  def database
    p "Initializing database"
    "database"
  end

  define(:logger) { "logger" }
  
  define(:lib) { LibApp.new }

  def add(x, y)
    x + y
  end

  def add_three(x, y, z)
    [rand, x+y+z]
  end
end

class Registry2 < Registry
  def database
    p "Initializing different database"
    "different database"
  end
end

class App
  inject :database, :logger
  inject :lib
  inject :add

  inject :add_three

  def test
    p self
    puts "I have: #{database}, #{logger}, #{lib}, #{add 2, 3}"
  end
end

class LibApp
  library LibApp, Registry

  inject :logger
end

p Dissident::LIBRARIES
p Dissident::INJECTED

Dissident.with Registry do
#  Dissident.with Registry, LibApp do
    a = App.new
    p a
    p a.test
#  end
end

Dissident.with Registry2,
               LibApp => Registry2 do
  App.new.test
  oy = nil
  Dissident.with Registry do
    oy = App.new
    oy.test
  end
  App.new.test
  oy.test
  oy.test
  oy.test

  a = App.new
  p a.add_three(1, 2, 3)
  p a.add_three(1, 2, 3)
  p a.add_three(1, 2, 3)
  p a.add_three(1, 2, 4)
  p a.add_three(1, 2, 3)
  p a.add_three(1, 1, 1)

  puts a.to_yaml
  p Marshal.dump(a)
  a.test
  p Marshal.dump(a)
  puts a.to_yaml
end

