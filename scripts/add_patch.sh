#!/bin/bash

LPATCH_ID=$(grep -m1 ^Patch ~/build/kernel/kernel.spec | awk '{ print $1 }' | sed s/Patch// | sed s/://)
NPATCH_ID=$(($LPATCH_ID + 1 ))
sed -i "/^Patch$LPATCH_ID:\ /a#\ $DESC\nPatch$NPATCH_ID:\ 0001-camflow.patch" ~/build/kernel/kernel.spec

sed -i "/ApplyOptionalPatch patch-%{patchversion}-redhat.patch/ a ApplyOptionalPatch 0001-camflow.patch" ~/build/kernel/kernel.spec
