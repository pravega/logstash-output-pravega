FROM docker.elastic.co/logstash/logstash-oss:7.15.2

ENV pravega_client_auth_method=Bearer
ENV pravega_client_auth_loadDynamic=true
COPY . /pravega
RUN bin/logstash-plugin install /pravega/logstash-output-pravega-0.10.1.gem

