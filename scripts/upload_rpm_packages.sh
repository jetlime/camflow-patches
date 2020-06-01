#!/bin/bash

for i in kernel-*.rpm
do
  echo "uploading $i to $1..."
  package_cloud push $1 $i
done
