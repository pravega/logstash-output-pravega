# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"
require "java"

require "pravega"

class LogStash::Outputs::Pravega < LogStash::Outputs::Base
  declare_threadsafe!

  config_name "pravega"

  default :codec, 'json'

  config :pravega_endpoint, :validate => :string, :require => true

  config :stream_name, :validate => :string, :required => true

  config :scope, :validate => :string, :default => 'global'

  config :num_of_segments, :validate => :number, :default => 1

  config :routing_key, :validate => :string, :default => ""


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
        uri = java.net.URI.new(pravega_endpoint)
        streamManager = StreamManager.create(uri)
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
        controllerURI = java.net.URI.new(pravega_endpoint)
        clientFactory = ClientFactory.withScope(scope, controllerURI)
        writer = clientFactory.createEventWriter(stream_name, JavaSerializer.new(), EventWriterConfig.builder().build()) 
    end
  end
end # class LogStash::Outputs::Pravega
