require 'spec/rake/spectask'

namespace :spec do
  desc "Run the specs under spec/lib"
  Spec::Rake::SpecTask.new(:lib => "db:test:prepare") do |t|
    t.spec_files = FileList['spec/lib/**/*_spec.rb']
  end

  desc "Run the engine specs in vendor/plugins/**/spec (or specify with ENGINE=name)"
  Spec::Rake::SpecTask.new(:engines => "db:test:prepare") do |t|
    if ENV['ENGINE']
      t.spec_files = FileList["vendor/plugins/#{ENV['ENGINE']}/spec/**/*_spec.rb"]
    else
      t.spec_files = FileList['vendor/plugins/**/spec/**/*_spec.rb']
    end
    t.spec_opts = ["-f h"]
    t.out = "spec.html"
  end
end
