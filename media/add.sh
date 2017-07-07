#!/bin/bash

for i in $(seq 0 4); do
  ./add$i.sh
  sleep 5
done
