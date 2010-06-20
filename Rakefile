namespace :xcode do
  
  namespace :build do
    
    desc %{Builds the Release configuration}
    task :release do
      sh "xcodebuild -configuration Release"
    end
    
    desc %{Builds the Debug configuration}
    task :debug do
      sh "xcodebuild -configuration Debug"
    end
    
    task :default => :release
    
  end
  
end

namespace :spec do
  
  task :init => "xcode:build:debug"
  
  desc %{Runs a single spec, passed as an argument}
  task :file => :init do
    sh "macruby /usr/bin/bacon #{ARGV[1]}"
  end
  
  desc %{Runs all specs in the spec folder}
  task :all => :init do
    sh "macruby /usr/bin/bacon spec/*_spec.rb"
  end
  
  desc %{Runs the spec for the provided ObjC file}
  task :for => :init do
    basename = File.basename(ARGV[1], ".*")
    spec_file = "spec/#{basename}_spec.rb"
    sh "macruby /usr/bin/bacon #{spec_file}"
  end
  
end

desc %{Runs the entire spec suite}
task :spec => 'spec:all'

task :default => 'spec'