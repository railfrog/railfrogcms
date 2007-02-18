#
# Dissident::Lifecycle -- a lifecycle manager for Dissident
#
# Copyright (C) 2005  Christian Neukirchen <chneukirchen@gmail.com>
#
# This work is licensed under the same terms as Ruby itself.
#

class << Dissident::Container
  alias_method :_provide, :provide
  def provide(name, klass, *services)
    _provide name, klass, *services
    Dissident::DEPENDENCIES[Dissident::LIBRARIES[self]][klass].concat services
  end
end

class Class
  _inject = instance_method :inject
  define_method(:inject) { |*names|
    _inject.bind(self).call *names
    Dissident::DEPENDENCIES[Dissident::LIBRARIES[self]][self].concat names
  }
end

module Dissident
  # A hash mapping classes to their dependencies.
  DEPENDENCIES = Hash.new { |h, k|
    h[k] = Hash.new { |l, m| l[m] = [] }
  }

  # Return the dependencies _klass_ has.
  def self.dependencies_for(klass)
    Dissident::DEPENDENCIES[klass]
  end
end

# Dissident::Lifecycle provides lifecycle management for Dissident.
#
# It redefines the +provide+ and +inject+ methods of Dissident to keep
# track of the services the klasses need.
#
# To use Dissident::Lifecycle, include it into your container.
# Dissident::Lifecycle uses ducktyping to figure out interfaces.
# Classes that can be <code>start</code>ed and <code>stop</code>ped
# need to define methods *both* methods, +start+ and +stop+.
# Classes that can be disposed need to implement +dispose+.
#
# Example:
#
#   class SampleContainer < Dissident::Container
#     include Dissident::Lifecycle
#   
#     provide :database, Database
#     provide :logger, Logger
#     provide :helper, Helper
#   end
#   
#   Dissident.with SampleContainer do |container|
#     container.start :database
#     ...
#     container.stop :database
#     container.dispose :database
#   end
module Dissident::Lifecycle
  # Call +start+ on all dependencies of _klass_ that support it and
  # _klass_.
  def start(klass)
    find_dependencies(klass, ["start", "stop"]) { |s| fetch(s).start }
    fetch(klass).start  rescue nil
  end

  # Call +stop+ on _klass_ and all dependencies of _klass_ that
  # support it.
  def stop(klass)
    fetch(klass).stop  rescue nil
    a = []
    find_dependencies(klass, ["start", "stop"]) { |s| a << s }
    a.reverse_each { |s| fetch(s).stop }
  end

  # Call +dispose+ on _klass_ and all dependencies of _klass_ that
  # support it.
  def dispose(klass)
    fetch(klass).dispose  rescue nil
    a = []
    find_dependencies(klass, ["dispose"]) { |s| a << s }
    a.reverse_each { |s| fetch(s).dispose }
  end

  private
  
  def find_dependencies(s, methods, &block)
    dep = Dissident.dependencies_for(Dissident::LIBRARIES[self]).dup
    klass = fetch(s).class
    container = Dissident.container_for klass

    dep.each { |k, v|
      dep[k] = v.map { |s|
        [s, container.fetch(s).class]  rescue nil
      }.compact.uniq   # needed??
    }

    walk(dep, klass, methods, &block)
  end

  def walk(dep, klass, methods, have={}, &block)
    dep[klass].each { |s|
      have.fetch(s.first) {
        have[s.first] = true
        walk(dep, s[1], methods, have, &block)
        block.call s.first  if (methods - s[1].instance_methods).empty?
      }      
    }
  end
end
