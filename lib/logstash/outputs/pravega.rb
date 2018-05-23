# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"
require "java"
require "logstash-output-pravega_jars.rb"

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
    create_stream
    logger.debug("created stream successfully", :stream => @stream_name)
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
    @producer.close
  end

  private
  def create_stream
    begin
        java_import("io.pravega.client.admin.StreamManager")
        java_import("io.pravega.client.admin.impl.StreamManagerImpl")
        java_import("io.pravega.client.stream.impl.Controller")
        java_import("io.pravega.client.stream.impl.ControllerImpl")
        java_import("io.pravega.client.stream.ScalingPolicy")
        java_import("io.pravega.client.stream.StreamConfiguration")
        java_import("io.pravega.client.ClientConfig")
        java_import("io.pravega.client.stream.impl.DefaultCredentials")
        uri = java.net.URI.new(pravega_endpoint)
        clientConfig = ClientConfig.builder()
                                   .controllerURI(uri)
                                   .credentials(DefaultCredentials.new(password, username))
                                   .validateHostName(false)
                                   .build()
        streamManager = StreamManager.create(clientConfig)
        streamManager.createScope(scope)
        policy = ScalingPolicy.fixed(num_of_segments)
        streamConfig = StreamConfiguration.builder().scalingPolicy(policy).build()
        streamManager.createStream(scope, stream_name, streamConfig)
    end
  end

  private
  def create_producer
    begin
        java_import("io.pravega.client.ClientFactory")
        java_import("io.pravega.client.stream.impl.JavaSerializer")
        java_import("io.pravega.client.stream.EventWriterConfig")
        uri = java.net.URI.new(pravega_endpoint)
        clientConfig = ClientConfig.builder()
                                   .controllerURI(uri)
                                   .credentials(DefaultCredentials.new(password, username))
                                   .validateHostName(false)
                                   .build()
        clientFactory = ClientFactory.withScope(scope, clientConfig)
        writer = clientFactory.createEventWriter(stream_name, JavaSerializer.new(), EventWriterConfig.builder().build()) 
    end
  end
end # class LogStash::Outputs::Pravega
