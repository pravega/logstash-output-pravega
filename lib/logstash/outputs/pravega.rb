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
  end # def register

  public
  def multi_receive_encoded(encoded)
    create_stream
    logger.debug("created stream successfully", :stream => @stream_name)
    @producer = create_producer
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
      java_import("com.emc.pravega.stream.impl.ClientFactoryImpl")
      java_import("com.emc.pravega.StreamManager")
      java_import("com.emc.pravega.stream.ScalingPolicy")
      java_import("com.emc.pravega.stream.impl.StreamConfiguration")
      java_import("com.emc.pravega.stream.impl.netty.ConnectionFactory")
      java_import("com.emc.pravega.stream.impl.netty.ConnectionFactoryImpl")
      java_import("com.emc.pravega.stream.impl.ControllerImpl")
      uri = java.net.URI.new(pravega_endpoint)
      controller = ControllerImpl(uri.getHost(), uri.getPort())
      connectionFactory = connectionFactory.new(false)
      @clientFactory = new ClientFactoryImpl(scope, controller, connectionFactory)
      streamManager = StreamManager.withScope(scope, uri)
      policy = ScalingPolicy.fixed(num_of_segments)
      config = StreamConfiguration.builder().scope(scope).streamName(stream_name).scalingPolicy(policy).build();
      streamManager.createStream(stream_name, config)
    end
  end

  private
  def create_producer
    begin
      java_import("com.emc.pravega.stream.EventWriterConfig")
      java_import("com.emc.pravega.stream.impl.JavaSerializer")
      writer = @clientFactory.createEventWriter(stream_name, JavaSerializer.new(), EventWriterConfig.builder().build())
    end
  end
end # class LogStash::Outputs::Pravega
