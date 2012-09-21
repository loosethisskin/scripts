#!/bin/bash

if [ -z "$1" ]; then
  echo "usage: build.sh <device> [degree]"
  exit 1
fi
device=$1
dop="$2"
if [ -z "$dop" ]; then
  dop=`cat /proc/cpuinfo| grep processor | wc -l`
fi

# ensure ccache is in the path
export PATH="$PATH:$PWD/prebuilt/$(uname|awk '{print tolower($0)}')-x86/ccache"

setup()
{
  USE_CCACHE=1
  CCACHE=ccache
  CCACHE_BASEDIR="$PWD"
  CCACHE_DIR="$PWD/.ccache"
  #export CCACHE_COMPRESS=1
  export USE_CCACHE CCACHE_DIR CCACHE_BASEDIR
  if [ ! "$(ccache -s|grep -E 'max cache size'|awk '{print $4}')" = "30.0" ]; then
    ccache -M 30G
  fi
  source build/envsetup.sh
  lunch cm_$1-userdebug
}

setup $device

LOGFILE=build_${device}_$(date +%Y%m%d_%H%M).log

START=$(date +%s)

#make -j`cat /proc/cpuinfo| grep processor | wc -l` bacon 2>&1 | tee $LOGFILE
make -j$dop bacon 2>&1 | tee $LOGFILE
#brunch $device 2>&1 | tee $LOGFILE

END=$(date +%s)
ELAPSED=$((END - START))
E_MIN=$((ELAPSED / 60))
E_SEC=$((ELAPSED - E_MIN * 60))
printf "Time to compile: " >> $LOGFILE
[ $E_MIN != 0 ] && printf "%d min(s) " $E_MIN >> $LOGFILE
printf "%d sec(s)\n" $E_SEC >> $LOGFILE

grep "Time to compile" $LOGFILE
