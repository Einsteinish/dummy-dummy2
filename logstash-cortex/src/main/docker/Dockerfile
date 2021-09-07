FROM docker.elastic.co/logstash/logstash:7.13.2

WORKDIR /usr/share/logstash
ADD config/* config/
ADD pipeline/* pipeline/  
ADD scripts/* scripts/

USER root
RUN mv pipeline/bogo.conf pipeline/logstash.conf

RUN echo "xpack.monitoring.enabled: false" >> config/logstash.yml
RUN chown -R logstash:root config pipeline scripts
USER logstash
