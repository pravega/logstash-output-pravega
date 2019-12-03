# Logstash Output Pravage Plugin

This is a plugin for [Logstash](https://github.com/elastic/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

## Documentation

Logstash provides infrastructure to automatically generate documentation for this plugin. We use the asciidoc format to write documentation so any comments in the source code will be first converted into asciidoc and then into html. All plugin documentation are placed under one [central location](http://www.elastic.co/guide/en/logstash/current/).

- For formatting code or config example, you can use the asciidoc `[source,ruby]` directive
- For more asciidoc formatting tips, see the excellent reference here https://github.com/elastic/docs#asciidoc-guide

The logstash-output-pravega plugin is upgraded to version: 0.4.0. It can be used to write data to [pravage-0.4.0](https://github.com/pravega/pravega/releases).

## Need Help?

Need help? Try #logstash on freenode IRC or the https://discuss.elastic.co/c/logstash discussion forum.

## Usage
- First, have rvm installed. Take how to install it on ubuntu-18~18.04.1 for example. For other OS, find it's installation in [rvm install](https://rvm.io/rvm/install)
```sh
sudo apt-get install software-properties-common
sudo apt-add-repository -y ppa:rael-gc/rvm
sudo apt-get update
sudo apt-get install -y rvm
```

- Have JRuby with the Bundler gem and mvn installed. It's suggested to install the latest version jrbuy as the old version has bugs.
```sh
rvm install jruby-9.1.17.0
rvm use jruby-9.1.17.0
gem install bundler
```

- Install dependencies
```sh
bundle install
```

- Install pravega client library
```sh
gem install rake
rake install_jars
```
- Build pravega output plugin (`logstash-output-pravega-<version>.gem` shall be generated at project root directory)
```sh
gem build logstash-output-pravega.gemspec
```
- Install plugin: ship `logstash-output-pravega-<version>.gem` to target host where logstash is installed
```sh
sudo bin/logstash-plugin install logstash-output-pravega-<version>.gem
```
- Configration
```
e.g.
output {
    pravega {
      pravega_endpoint => "tcp://<host>:<port>"
      stream_name => "myStream"
    }
  }
}
```
```
  # other optional configs. When the controller authorization of pravega is open, the usename and password is required.

      scope:             default: 'global'
      num_of_segments:   default: 1
      routing_key:       default: ""
      username:          default: ""
      password:          default: ""
```

- Restart logstash

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

#### 2.3 Run it in K8S

- Build your plugin gem
- build docker image and push it to your docker registry
```sh
export DOCKER_REPOSITORY=mydockerregitry.com
docker build -t ${DOCKER_REPOSITORY}/logstash-pravega:0.6.0 .
docker push  ${DOCKER_REPOSITORY}/logstash-pravega:0.6.0
```
- Deploy it to K8S using helm install
```
helm upgrade --install logstash-pravega \
     --namespace mynamespace  charts/logstash/ \
     --set image.repository=${DOCKER_REPOSITORY}/logstash-pravega\
     --set image.tag=0.6.0 stable/logstash
```

## Contributing

All contributions are welcome: ideas, patches, documentation, bug reports, complaints, and even something you drew up on a napkin.

Programming is not a required skill. Whatever you've seen about open source and maintainers or community members  saying "send patches or die" - you will not see that here.

It is more important to the community that you are able to contribute.

For more information about contributing, see the [CONTRIBUTING](https://github.com/elastic/logstash/blob/master/CONTRIBUTING.md) file.
