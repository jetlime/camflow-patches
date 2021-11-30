#!/bin/bash

for i in ~/build/kernel/*-fedora.config
do
	echo $i
  cat ./extra-conf >> $i
	sed -i -e "s/CONFIG_LSM=\"lockdown,yama,integrity,selinux,bpf,landlock\"/CONFIG_LSM=\"lockdown,yama,integrity,selinux,bpf,landlock,provenance\"/g" $i
done
