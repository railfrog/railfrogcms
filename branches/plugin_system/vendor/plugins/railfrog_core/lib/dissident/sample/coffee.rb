# Coffee machine example taken from Jim Weirich's OSCON 2005 slides
# and rewritten in Dissident.

require 'dissident'

class PotSensor
  def initialize(port)
    @port = port
  end

  def coffee_present?
    #...
  end
end

class MockSensor < PotSensor; end

class Heater
  def initialize(port)
    @port = port
  end

  def on
    #...
  end
  def off
    #...
  end
end

class MockHeater < Heater; end

class Warmer
  inject :pot_sensor
  inject :heater

  def trigger
    if pot_sensor.coffee_present?
      heater.on
    else
      heater.off
    end
  end
end


class MarkIVConfiguration < Dissident::Container
  constant :pot_sensor_io_port, 0x08F0
  constant :heater_io_port, 0x08F1

  provide :pot_sensor, PotSensor, :pot_sensor_io_port
  provide :heater, Heater, :heater_io_port
  provide :warmer, Warmer
end

class MarkIVTestConfig < MarkIVConfiguration
  provide :heater, MockHeater
  provide :pot_sensor, MockSensor
end

Dissident.with MarkIVConfiguration do |d|
  d.warmer
end

# -or-

Dissident.with MarkIVConfiguration do
  w = Warmer.new
  w.trigger
end
