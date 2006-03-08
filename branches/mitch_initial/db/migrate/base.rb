module ActiveRecord
  class Migration
    @@version = '?'
    
    class << self 
      def set_version(version)
        @@version = version
      end
    
      def log(msg)
        STDERR.puts 'Version ' + @@version + ': ' + msg
      end
    end
  end
end