#!/bin/bash

java -Xmx1g -jar {{reaper_dir}}/target/cassandra-reaper-{{reaper_version}}-SNAPSHOT.jar server {{reaper_dir}}/reaper.yaml &

