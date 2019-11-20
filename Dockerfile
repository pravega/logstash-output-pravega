FROM docker.elastic.co/logstash/logstash:7.1.1

ENV pravega_client_auth_method=Bearer

ENV pravega_client_auth_loadDynamic=true

ADD config/ /usr/share/logstash/config/
COPY . /pravega
RUN bin/logstash-plugin install /pravega/logstash-output-pravega-0.6.0.gem

ENTRYPOINT ["bin/logstash","-f","/pravega/config/logstash.conf"]
