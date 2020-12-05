#!/bin/bash

LPATCH_ID=$(grep ^Patch ~/build/kernel/kernel.spec | tail -n1 | awk '{ print $1 }' | sed s/Patch// | sed s/://)
NPATCH_ID=$(($LPATCH_ID + 1 ))
sed -i "/^Patch$LPATCH_ID:\ /a#\ $DESC\nPatch$NPATCH_ID:\ 0001-information-flow.patch" ~/build/kernel/kernel.spec
cat ~/build/kernel/kernel.spec | grep $NPATCH_ID
NPATCH_ID=$(($NPATCH_ID + 1 ))
sed -i "/^Patch$LPATCH_ID:\ /a#\ $DESC\nPatch$NPATCH_ID:\ 0002-camflow.patch" ~/build/kernel/kernel.spec
cat ~/build/kernel/kernel.spec | grep $NPATCH_ID
