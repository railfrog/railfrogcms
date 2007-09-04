require 'dissident'
require 'dissident/lifecycle'

class Helper
  def start; p "Starting Helper"; end
  def stop; p "Stopping Helper"; end
  def dispose; p "Disposing Helper"; end
end

class Database
  inject :logger
  inject :helper
  def start; p "Starting Database"; end
  def stop; p "Stopping Database"; end
  def dispose; p "Disposing Database"; end
end

class Logger
  inject :helper
  def start; p "Starting Logger"; end
  def stop; p "Stopping Logger"; end
end

class SampleContainer < Dissident::Container
  include Dissident::Lifecycle

  provide :database, Database
  provide :logger, Logger
  provide :helper, Helper
end

p Dissident::DEPENDENCIES

Dissident.with SampleContainer do |container|
  container.start :database
  p :hum
  container.stop :database
  container.dispose :database
end
