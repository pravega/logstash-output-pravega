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
  end # def register

  public
  def multi_receive_encoded(encoded)
    pre_check(encoded)
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
    @producer.close()
  end

  private
  def pre_check(encoded)
    # If the num_of_segment <= 0, the IllegalArgumentException will be thrown and logstash will stop.
    @num_of_segments = 1 if @num_of_segments <= 0

    # If the input stream name is same as output, it will filter the formatted json data again and again without endless.
    # So, the new output streamName needs to be created
    encoded.each do |event, data|
      if @stream_name == JSON.parse(data)['streamName']
        @stream_name = "newOutputStream-".concat(SecureRandom.uuid)
	logger.info("The input stream_name shouldn't be equal to output, the new output_stream is created", :stream_name => @stream_name)
	break
      end
    end
    logger.debug("After arugument preCheck ", :num_of_segments => @num_of_segments, :stream_name => @stream_name)
  end

  private
  def create_producer
    begin
      java_import("io.pravega.client.admin.StreamManager")
      java_import("io.pravega.client.stream.ScalingPolicy")
      java_import("io.pravega.client.stream.StreamConfiguration")
      java_import("io.pravega.client.ClientConfig")
      java_import("io.pravega.client.stream.impl.DefaultCredentials")
      java_import("io.pravega.client.EventStreamClientFactory")
      java_import("io.pravega.client.stream.impl.JavaSerializer")
      java_import("io.pravega.client.stream.EventWriterConfig")

      uri = java.net.URI.new(pravega_endpoint)
      clientConfig = ClientConfig.builder()
                                 .controllerURI(uri)
                                 .credentials(DefaultCredentials.new(password, username))
                                 .validateHostName(false)
                                 .build()
      streamManager = StreamManager.create(clientConfig)
      streamManager.createScope(scope)
      policy = ScalingPolicy.fixed(@num_of_segments)
      streamConfig = StreamConfiguration.builder().scalingPolicy(policy).build()
      streamManager.createStream(scope, stream_name, streamConfig)
      logger.debug("created stream successfully", :stream => @stream_name)

      clientFactory = EventStreamClientFactory.withScope(scope, clientConfig)
      writer = clientFactory.createEventWriter(stream_name, JavaSerializer.new(), EventWriterConfig.builder().build())
    end
  end
end # class LogStash::Outputs::Pravega
