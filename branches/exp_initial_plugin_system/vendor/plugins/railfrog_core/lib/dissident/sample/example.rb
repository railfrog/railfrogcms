# Playing with various features of Dissident.

require 'dissident'
require 'yaml'

class LibApp; end

class MyContainer < Dissident::Container
  def database
    p "Initializing database"
    "database"
  end

  define(:logger) { "logger" }
  
  provide :lib, LibApp

  def add(x, y)
    x + y
  end

  def add_three(x, y, z)
    [rand, x+y+z]
  end
end

class MyContainer2 < MyContainer
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
  library LibApp
  default_container MyContainer

  inject :logger
end

p Dissident::LIBRARIES
p Dissident::INJECTED

Dissident.with MyContainer do
  a = App.new
  p a
  p a.test
end

Dissident.with MyContainer2,
               LibApp => MyContainer2 do
  App.new.test
  oy = nil
  Dissident.with MyContainer do
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
  a.test
  puts a.to_yaml
end

