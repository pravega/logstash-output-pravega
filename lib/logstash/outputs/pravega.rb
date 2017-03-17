# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"
require "java"
# require pravega jar dependencies
require "client"
require "common"
require "contract"
# TODO other pravega dependencies
require "commons-lang-2.6"
require "guava-16.0"
require "libthrift-0.9.1"
require "netty-all-4.0.36.Final"
require "slf4j-api-1.7.14"

class LogStash::Outputs::Pravega < LogStash::Outputs::Base
  declare_threadsafe!

  config_name "pravega"

  default :codec, 'json'

  config :pravega_endpoint, :validate => :string, :require => true

  config :stream_name, :validate => :string, :required => true

  config :scope, :validate => :string, :default => 'global'

  config :target_rate, :validate => :number, :default => 100
  
  config :scale_factor, :validate => :number, :default => 1

  config :min_num_segments, :validate => :number, :default => 1

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
      java_import("com.emc.pravega.ClientFactory")
      java_import("com.emc.pravega.StreamManager")
      java_import("com.emc.pravega.stream.ScalingPolicy")
      java_import("com.emc.pravega.stream.impl.StreamConfigurationImpl")
      uri = java.net.URI.new(pravega_endpoint)
      clientFactory = ClientFactory.withScope(scope, uri)
      streamManager = StreamManager.withScope(scope, uri)
      policy = ScalingPolicy.new(ScalingPolicy::Type::FIXED_NUM_SEGMENTS, target_rate, scale_factor, min_num_segments)
      streamManager.createStream(stream_name, StreamConfigurationImpl.new(scope, stream_name, policy))
    end
  end

  private
  def create_producer
    begin
      java_import("com.emc.pravega.ClientFactory")
      java_import("com.emc.pravega.StreamManager")
      java_import("com.emc.pravega.stream.EventWriterConfig")
      java_import("com.emc.pravega.stream.impl.JavaSerializer")
      uri = java.net.URI.new(pravega_endpoint)
      clientFactory = ClientFactory.withScope(scope, uri)
      streamManager = StreamManager.withScope(scope, uri)
      writer = clientFactory.createEventWriter(stream_name, JavaSerializer.new(), EventWriterConfig.new(nil))
    end
  end
end # class LogStash::Outputs::Pravega
