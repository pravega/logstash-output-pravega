FROM docker.elastic.co/logstash/logstash-oss:7.16.0

#ENV DEBUG=1

ENV pravega_client_auth_method=Bearer
ENV pravega_client_auth_loadDynamic=true
COPY . /pravega
RUN   echo "OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE)" >> lib/pluginmanager/install.rb
RUN bin/logstash-plugin install  /pravega/logstash-output-pravega-0.10.1.gem

