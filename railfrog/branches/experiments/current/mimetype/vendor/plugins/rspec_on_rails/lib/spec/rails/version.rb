module Spec
  module Rails
    module VERSION
      unless defined?(REV)
        # RANDOM_TOKEN: 0.0576964611027444
        # REV = "$LastChangedRevision: 1407 $".match(/LastChangedRevision: (\d+)/)[1]
        # NOTE - need to hardcode this because the 0.7.5.1 gem has rev 1395
        #        while this tagged release was released at 1394
        REV = "1395"
      end
    end
  end
end

# Verifies that the plugin has the same revision as RSpec
if Spec::VERSION::REV != Spec::Rails::VERSION::REV
  raise <<-EOF

############################################################################
Your RSpec on Rails plugin is incompatible with your installed RSpec.

RSpec          : #{Spec::VERSION::FULL_VERSION}
RSpec on Rails : r#{Spec::Rails::VERSION::REV}

Make sure your RSpec on Rails plugin is compatible with your RSpec gem.
See http://rspec.rubyforge.org/documentation/rails/install.html for details.
############################################################################
EOF
end