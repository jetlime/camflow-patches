#!/bin/bash
for i in build/kernel/*-fedora.config
do
	echo $i
  cat ./extra-conf >> $i
done
