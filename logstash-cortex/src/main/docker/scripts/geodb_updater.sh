#!/bin/bash
#Automation script for auto-update of Logstash's geodb

GDB_URL='http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz'
WORKDIR='/tmp/geoupdate'
GEODB_PATH='/usr/share/logstash/vendor/bundle/jruby/2.3.0/gems/logstash-filter-geoip-5.0.1-java/vendor/GeoLite2-City.mmdb'

while [ true ]
do
  sleep 100
  mkdir -p $WORKDIR
  cd $WORKDIR

  curl -s $GDB_URL -o $WORKDIR/geo.tar.gz

  tar -xvf geo.tar.gz

  FOLDER=$(ls | grep GeoLite2)
  mv $FOLDER/GeoLite2-City.mmdb $GEODB_PATH

  cd /
  rm -rf $WORKDIR
  sleep 86400
done
