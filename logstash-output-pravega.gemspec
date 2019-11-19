Gem::Specification.new do |s|
  s.name          = 'logstash-output-pravega'
  s.version       = '0.6.0'
  s.licenses      = ['Apache License (2.0)']
  s.summary       = 'Output events to a Pravega Stream. This uses the Pravega Writer API to write event to a stream on the Pravega'
  s.description   = 'This gem is a Logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/logstash-plugin install gemname. This gem is not a stand-alone program'
  s.authors       = ['Ben Wang', 'Tony Li', 'Lingling.Yao']
  s.email         = 'ben.wang@emc.com'
  s.require_paths = ['lib']

  # Files
  s.files = Dir["lib/**/*.rb","spec/**/*","*.gemspec","*.md","CONTRIBUTORS","Gemfile","LICENSE","NOTICE.TXT", "vendor/jar-dependencies/**/*"]

   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "output" }

  s.requirements << "jar 'io.pravega:pravega-client', '0.6.0'"

  # Gem dependencies
  s.add_runtime_dependency "logstash-core-plugin-api", ">= 1.60", "<= 2.99"
  s.add_runtime_dependency 'logstash-codec-plain', '>= 0'
  s.add_runtime_dependency 'stud', '>= 0.0', '>= 0.0.22'
  s.add_development_dependency 'logstash-devutils', '>= 0.0', '>= 0.0.16'
  s.add_development_dependency 'jar-dependencies', '>= 0.3.2'
  s.add_development_dependency 'json', '>= 1.8.3'
end
