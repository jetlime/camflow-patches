#!/bin/bash

for i in linux-*.deb
do
  echo "uploading $i to $1..."
  package_cloud push $1 $i
done
