#!/bin/bash

java -Xmx1g -jar /opt/cassandra-reaper/cassandra-reaper.jar server /opt/cassandra-reaper/reaper.yaml &

