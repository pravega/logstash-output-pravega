# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"
require "java"
require "logstash-output-pravega_jars.rb"
require "json"

class LogStash::Outputs::Pravega < LogStash::Outputs::Base
  declare_threadsafe!

  config_name "pravega"

  default :codec, 'json'

  config :pravega_endpoint, :validate => :string, :require => true

  config :stream_name, :validate => :string, :required => true

  config :scope, :validate => :string, :default => 'global'

  config :num_of_segments, :validate => :number, :default => 1

  config :routing_key, :validate => :string, :default => ""

  config :username, :validate => :string, :default => ""

  config :password, :validate => :string, :default => ""


  public
  def register
     @clientFactory = get_client_factory
     @producer = create_producer
  end # def register

  public
  def multi_receive_encoded(encoded)
    encoded.each do |event,data|
      begin
        @producer.writeEvent(routing_key,data)
        logger.debug("write in stream succssfully", :stream_name => @stream_name, :event => data)
      rescue LogStash::ShutdownSignal
        logger.debug("Pravega producer got shutdown signal")
      rescue => e
        logger.warn("Pravega producer threw exception, restarting", :exception => e)
      end
    end
  end

  def close
    @clientFactory.close()
    @producer.close()
  end

  private
  def get_client_factory
    begin
      java_import("io.pravega.client.admin.StreamManager")
      java_import("io.pravega.client.stream.ScalingPolicy")
      java_import("io.pravega.client.stream.StreamConfiguration")
      java_import("io.pravega.client.ClientConfig")
      java_import("io.pravega.client.stream.impl.DefaultCredentials")
      java_import("io.pravega.client.ClientFactory")
      java_import("io.pravega.client.stream.impl.UTF8StringSerializer")
      java_import("io.pravega.client.stream.EventWriterConfig")

      uri = java.net.URI.new(pravega_endpoint)
      clientConfig = ClientConfig.builder()
                                 .controllerURI(uri)
                                 .validateHostName(false)
                                 .build()
      streamManager = StreamManager.create(clientConfig)
      policy = ScalingPolicy.fixed(@num_of_segments)
      streamConfig = StreamConfiguration.builder().scalingPolicy(policy).build()
      streamManager.createStream(scope, stream_name, streamConfig)
      logger.debug("created stream successfully", :stream => @stream_name)
      streamManager.close()
      clientFactory = ClientFactory.withScope(scope, clientConfig)

  private
  def create_producer
    begin
      java_import("io.pravega.client.stream.impl.UTF8StringSerializer")
      java_import("io.pravega.client.stream.EventWriterConfig")
      writer = @clientFactory.createEventWriter(stream_name, UTF8StringSerializer.new(), EventWriterConfig.builder().build())
    end
  end
end # class LogStash::Outputs::Pravega
