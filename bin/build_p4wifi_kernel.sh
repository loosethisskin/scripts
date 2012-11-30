#!/bin/bash

if [ -z "$1" ]; then
  echo "usage: build_p4wifi_kernel.sh <toolchaindir>"
  exit 1
fi

TOOLCHAIN_DIR=$1
SOURCE_DIR="$PWD"

v_toolchain=`basename $TOOLCHAIN_DIR`
v_gcc=gcc-`gcc --version |head -1 |awk '{ print $NF }'`

#export PATH="$PATH:/u01/dev/android/sgt7/cm9/prebuilt/linux-x86/ccache"
export PATH=$TOOLCHAIN_DIR/bin:$PATH
export CCOMPILER="$TOOLCHAIN_DIR/bin/arm-eabi-"
# ensure ccache is in the path
export PATH="$PATH:/u01/dev/android/p4wifi/cm10/prebuilts/misc/$(uname|awk '{print tolower($0)}')-x86/ccache"

USE_CCACHE=1
CCACHE=ccache
CCACHE_DIR="$PWD/.ccache"
export USE_CCACHE CCACHE_DIR CCACHE_BASEDIR
if [ ! "$(ccache -s|grep -E 'max cache size'|awk '{print $4}')" = "10.0" ]; then
	ccache -M 10G
fi

LOGFILE=build_kernel_$(date +%Y%m%d_%H%M)_${v_toolchain}_${v_gcc}.log
rm -f $LOGFILE
echo "TOOLCHAIN = $TOOLCHAIN_DIR" | tee -a $LOGFILE
gcc --version | tee -a $LOGFILE

echo "Cleaning up..."
OUTPUT_DIR=$SOURCE_DIR/out
rm -rf $OUTPUT_DIR
[ $? -ne 0 ] && exit 1
mkdir -p $OUTPUT_DIR
[ $? -ne 0 ] && exit 1

START=$(date +%s)

make O=$OUTPUT_DIR ARCH=arm CROSS_COMPILE=$CCOMPILER distclean
make O=$OUTPUT_DIR ARCH=arm CROSS_COMPILE=$CCOMPILER pershoot_samsung_p4wifi-jb_defconfig 2>&1 | tee -a $LOGFILE
make -j 4 ARCH=arm CROSS_COMPILE=$CCOMPILER | tee -a $LOGFILE

#make O=$OUTPUT_DIR ARCH=arm distclean
#make O=$OUTPUT_DIR ARCH=arm CROSS_COMPILE=$CCOMPILER pershoot_samsung_p4wifi-jb_defconfig 2>&1 | tee -a $LOGFILE
#time make -j 4 O=$OUTPUT_DIR ARCH=arm CROSS_COMPILE=$CCOMPILER uImage 2>&1 | tee -a $LOGFILE
#time make -j 4 O=$OUTPUT_DIR ARCH=arm CROSS_COMPILE=$CCOMPILER uImage2>&1 | tee -a $LOGFILE

END=$(date +%s)
ELAPSED=$((END - START))
E_MIN=$((ELAPSED / 60))
E_SEC=$((ELAPSED - E_MIN * 60))
printf "Time to compile: " >> $LOGFILE
[ $E_MIN != 0 ] && printf "%d min(s) " $E_MIN >> $LOGFILE
printf "%d sec(s)\n" $E_SEC >> $LOGFILE

grep "Time to compile" $LOGFILE
