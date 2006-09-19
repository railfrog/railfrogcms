Dir["./vendor/railfrog_plugins/gems/*/tasks/**/*.rake"].sort.each { |ext| load ext }

#namespace :railfrog do
#  namespace :plugins do
#    desc "Enable Plugin"
#    task :enable do
#    end
#    
#    desc "Disable Plugin"
#    task :disable do
#    end
#  end
#end
