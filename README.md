# Logstash Plugin

This is a plugin for [Logstash](https://github.com/elastic/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

## Documentation

Logstash provides infrastructure to automatically generate documentation for this plugin. We use the asciidoc format to write documentation so any comments in the source code will be first converted into asciidoc and then into html. All plugin documentation are placed under one [central location](http://www.elastic.co/guide/en/logstash/current/).

- For formatting code or config example, you can use the asciidoc `[source,ruby]` directive
- For more asciidoc formatting tips, see the excellent reference here https://github.com/elastic/docs#asciidoc-guide

## Need Help?

Need help? Try #logstash on freenode IRC or the https://discuss.elastic.co/c/logstash discussion forum.

## Usage

- Have JRuby with the Bundler gem and mvn installed
- Install dependencies
```sh
bundle install
```
- Install pravega client library
```sh
jrake install_jars
```
- Build pravega output plugin (`logstash-output-pravega-<version>.gem` shall be generated at project root directory)
```
jgem build logstash-output-pravega.gemspec
```
- Install plugin: ship `logstash-output-pravega-<version>.gem` to target host where logstash is installed
```
logstash-plugin install logstash-output-pravega-<version>.gem
```

- NOTE: Resolve jar version conflict (only if you also want to use beats plugin). It's a known issue for logstash. To fix it, we need to replace netty-all jar in beats plugin by the one in pravega plugin
```
e.g.
$ pwd
/usr/local/Cellar/logstash/5.5.2
$ find . -name netty-all-*.Final.jar
./libexec/vendor/bundle/jruby/1.9/gems/logstash-input-beats-3.1.23-java/vendor/jar-dependencies/io/netty/netty-all/4.1.3.Final/netty-all-4.1.3.Final.jar
./libexec/vendor/local_gems/4f0cb3fe/logstash-output-pravega-0.2.0/vendor/jar-dependencies/runtime-jars/netty-all-4.1.8.Final.jar

$ cp ./libexec/vendor/local_gems/4f0cb3fe/logstash-output-pravega-0.2.0/vendor/jar-dependencies/runtime-jars/netty-all-4.1.8.Final.jar ./libexec/vendor/bundle/jruby/1.9/gems/logstash-input-beats-3.1.23-java/vendor/jar-dependencies/io/netty/netty-all/4.1.3.Final/netty-all-4.1.3.Final.jar
```

- Configration
```
e.g.
output {
    pravega {
      pravega_endpoint => "tcp://<host>:<port>"
      stream_name => "myStream"
      scope => "myScope"
      #username => "admin"
      #password => "1111_aaaa"
    }
  }
}
```
```
  # other optional configs

  codec:           default 'json'
  num_of_segments: default 1
  routing_key    : default ""
```

- [Re]start logstash

## Developing

### 1. Plugin Developement and Testing

#### Code
- To get started, you'll need JRuby with the Bundler gem installed.

- Create a new plugin or clone and existing from the GitHub [logstash-plugins](https://github.com/logstash-plugins) organization. We also provide [example plugins](https://github.com/logstash-plugins?query=example).

- Install dependencies
```sh
bundle install
```

#### Test

- Update your dependencies

```sh
bundle install
```

- Run tests

```sh
bundle exec rspec
```

### 2. Running your unpublished Plugin in Logstash

#### 2.1 Run in a local Logstash clone

- Edit Logstash `Gemfile` and add the local plugin path, for example:
```ruby
gem "logstash-filter-awesome", :path => "/your/local/logstash-filter-awesome"
```
- Install plugin
```sh
bin/logstash-plugin install --no-verify
```
- Run Logstash with your plugin
```sh
bin/logstash -e 'filter {awesome {}}'
```
At this point any modifications to the plugin code will be applied to this local Logstash setup. After modifying the plugin, simply rerun Logstash.

#### 2.2 Run in an installed Logstash

You can use the same **2.1** method to run your plugin in an installed Logstash by editing its `Gemfile` and pointing the `:path` to your local plugin development directory or you can build the gem and install it using:

- Build your plugin gem
```sh
gem build logstash-filter-awesome.gemspec
```
- Install the plugin from the Logstash home
```sh
bin/logstash-plugin install /your/local/plugin/logstash-filter-awesome.gem
```
- Start Logstash and proceed to test the plugin

## Contributing

All contributions are welcome: ideas, patches, documentation, bug reports, complaints, and even something you drew up on a napkin.

Programming is not a required skill. Whatever you've seen about open source and maintainers or community members  saying "send patches or die" - you will not see that here.

It is more important to the community that you are able to contribute.

For more information about contributing, see the [CONTRIBUTING](https://github.com/elastic/logstash/blob/master/CONTRIBUTING.md) file.
