#!/bin/bash

if [ -z "$1" ]; then
  echo "usage: build.sh <device>"
  exit 1
fi
device=$1

#SOURCE_DIR="$(dirname "$(readlink -f "$0")")"
SOURCE_DIR="$PWD"
echo SOURCE_DIR=$SOURCE_DIR

# ensure ccache is in the path
export PATH="$PATH:$PWD/prebuilt/$(uname|awk '{print tolower($0)}')-x86/ccache"

setup()
{
  USE_CCACHE=1
  CCACHE=ccache
  CCACHE_BASEDIR="$SOURCE_DIR"
  CCACHE_DIR="$SOURCE_DIR/.ccache"
  #export CCACHE_COMPRESS=1
  export USE_CCACHE CCACHE_DIR CCACHE_BASEDIR
  if [ ! "$(ccache -s|grep -E 'max cache size'|awk '{print $4}')" = "5.0" ]; then
    ccache -M 5G
  fi
  source build/envsetup.sh
  lunch aokp_$1-userdebug
}

setup $device

LOGFILE=build_$(date +%Y%m%d_%H%M).log

START=$(date +%s)

#make CC=gcc-4.4 CXX=g++-4.4 -j`cat /proc/cpuinfo| grep processor | wc -l` otapackage 2>&1 | tee $LOGFILE 
#make -j`cat /proc/cpuinfo| grep processor | wc -l` bacon 2>&1 | tee $LOGFILE
make -j`cat /proc/cpuinfo| grep processor | wc -l` otapackage | tee $LOGFILE
#brunch $device 2>&1 | tee $LOGFILE

END=$(date +%s)
ELAPSED=$((END - START))
E_MIN=$((ELAPSED / 60))
E_SEC=$((ELAPSED - E_MIN * 60))
printf "Time to compile: " >> $LOGFILE
[ $E_MIN != 0 ] && printf "%d min(s) " $E_MIN >> $LOGFILE
printf "%d sec(s)\n" $E_SEC >> $LOGFILE

grep "Time to compile" $LOGFILE
