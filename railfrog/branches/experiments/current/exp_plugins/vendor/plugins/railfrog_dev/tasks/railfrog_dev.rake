require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'

namespace :railfrog do
  namespace :spec do
    
    file_list = ['vendor/plugins/railfrog*/spec/**/*_spec.rb', 'vendor/railfrog-plugins/gems/*/spec/**/*_spec.rb']
    spec_opts = ['--format h', '--out', 'doc/railfrog/report.html']

    desc "Run all Railfrog-related specs and write report to doc/railfrog/report.html" 
    Spec::Rake::SpecTask.new(:report) do |t|
      t.spec_files = FileList.new(*file_list)
      t.spec_opts = spec_opts
      t.fail_on_error = false
      t.failure_message = "The specs failed. Check for the problem at doc/railfrog/report.html" 
    end

    desc "Run all Railfrog-related specs with RCov and write output to doc/railfrog/" 
    Spec::Rake::SpecTask.new(:rcov) do |t|
      t.spec_files = FileList[*file_list]
      t.spec_opts = spec_opts #Don't output HTML report in this task?
      t.rcov = true
      t.rcov_dir = 'doc/railfrog/coverage'
      t.rcov_opts = ['--exclude', 'spec/', '--rails']
      t.fail_on_error = false
      t.failure_message = "The specs failed. Check for the problem at doc/railfrog/report.html" 
    end
    
    desc "Verify coverage threshold" 
    RCov::VerifyTask.new(:verify_rcov => :rcov) do |t|
      t.threshold = 100.0
      t.index_html = 'doc/railfrog/coverage/index.html'
    end
    
  end
end