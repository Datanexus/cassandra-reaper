#!/bin/bash

sh -c 'ps fax | grep cassandra-reaper | cut -d" " -f2 | xargs kill '

