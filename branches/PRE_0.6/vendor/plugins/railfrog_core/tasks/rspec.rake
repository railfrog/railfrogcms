require 'spec/rake/spectask'

namespace :spec do  
  desc "Run the specs under vendor/railfrog_core (Use RCOV=true to run with rcov)"
  Spec::Rake::SpecTask.new(:railfrog => "db:test:prepare") do |t|
    t.spec_files = FileList['vendor/plugins/railfrog_core/spec/**/*_spec.rb']
    if ENV["RCOV"] == 'true'
      t.rcov = true
      t.rcov_opts = ["--rails", "--exclude", '\bspec/,_spec\.rb\z', "--include-file", '"\bvendor\/plugins\/railfrog_core\/(?!spec\/)"']
    end
  end
end