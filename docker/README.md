# Pravega Demo In Docker Container

This is for running the following pipeline in a Docker container:
```
Apache access logs -> Logstash with Pravega output plugin -> Pravega stream
```

Applications, e.g., Flink jobs, can then read the data from Pravega stream and process them. 

Services running inside the container.
- Pravega standalone. See more details [here](http://pravega.io/docs/latest/getting-started/)
- Logstash with [Pravega output plugin](https://github.com/pravega/logstash-output-pravega). It is configured to read data from a file that contains Apache access logs and push the logs, by default, to Pravega standalone running inside the container. 

The Docker image is prebuilt at https://hub.docker.com/r/emccorp/pravega-demo. 

To start, first create a file at /tmp/access.log
```
$ touch /tmp/access.log
```

Then run script below to start container from prebuilt image. Adjust parameters to your need.
```
#!/bin/sh
set -u

PRAVEGA_SCOPE=myscope
PRAVEGA_STREAM=apacheaccess
CONTAINER_NAME=pravega
IMAGE_NAME=emccorp/pravega-demo

docker run -d --name $CONTAINER_NAME \
    -p 9090:9090 \
    -p 9091:9091 \
    -v /tmp/access.log:/opt/data/access.log \
    -v /tmp/logs/:/var/log/pravega/ \
    -e PRAVEGA_ENDPOINT=${PRAVEGA_ENDPOINT} \
    -e PRAVEGA_SCOPE=${PRAVEGA_SCOPE} \
    -e PRAVEGA_STREAM=${PRAVEGA_STREAM} \
    ${IMAGE_NAME} 
```
The logs files can be found under at /tmp/logs.

Add access logs to /tmp/access.log, e.g., by runing the command below a few times.
```
echo '10.1.1.11 - peter [19/Mar/2018:02:24:01 -0400] "PUT /mapping/ HTTP/1.1" 500 182 "http://example.com/myapp" "python-client"' >> /tmp/access.log
```

The logs are sent to Pravega stream as json string, for example.
```
{
        "request" => "/mapping/",
          "agent" => "\"python-client\"",
           "auth" => "peter",
          "ident" => "-",
           "verb" => "PUT",
        "message" => "10.1.1.11 - peter [19/Mar/2018:02:24:01 -0400] \"PUT /mapping/ HTTP/1.1\" 500 182 \"http://example.com/myapp\" \"python-client\"",
           "path" => "/opt/data/access.log",
       "referrer" => "\"http://example.com/myapp\"",
     "@timestamp" => 2018-03-19T06:24:01.000Z,
       "response" => "500",
          "bytes" => "182",
       "clientip" => "10.1.1.11",
       "@version" => "1",
           "host" => "5e91529a729f",
    "httpversion" => "1.1"
}
```

You can then start a Pravega reader to read from it, e.g., [Pravega Samples](https://github.com/pravega/pravega-samples)


In case you want to build the images yourself

Clone this repository
```
$ git clone https://github.com/hldnova/pravega-docker.git
```

Build with tag, e.g., pravega-demo
```
$ cd pravega-docker 
$ docker build --rm=true -t pravega-demo . 
```

To run with your image, just replace `emccorp/pravega-demo` with your image tag, in this case, `pravega-demo`.
