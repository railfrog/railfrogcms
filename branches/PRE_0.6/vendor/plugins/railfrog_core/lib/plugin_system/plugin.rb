module RailFrog
  module PluginSystem
    class Plugin
      attr_reader :database, :specification
      
      def initialize(specification_file)
      end
      
      def enabled?
        @database.enabled?
      end
      
      def disabled?
        not enabled?
      end
      
      def started?
        true
      end
    end
  end
end