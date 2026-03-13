#!/bin/bash

start=$(date +%s)

THREADS=$(nproc --all)
TOOLCHAIN=${TOOLCHAIN:-"$HOME/android/toolchain/proton-clang"}

if [ ! -d "$TOOLCHAIN/bin" ]; then
  echo "ERROR: Toolchain not found!"
  echo "Please set TOOLCHAIN path."
  echo ""
  echo "Example:"
  echo "export TOOLCHAIN=~/clang"
  exit 1
fi

echo "======================================"
echo "Cortena Kernel Build Script"
echo "Device : merlin"
echo "Threads: $THREADS"
echo "Start  : $(date)"
echo "======================================"

export PATH=$TOOLCHAIN/bin:$PATH
export ARCH=arm64
export SUBARCH=arm64

rm -rf out
mkdir out

make O=out merlin_defconfig

make -j$THREADS O=out \
  ARCH=arm64 \
  CC=clang \
  CLANG_TRIPLE=aarch64-linux-gnu- \
  CROSS_COMPILE=aarch64-linux-gnu- \
  CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
  AR=llvm-ar \
  NM=llvm-nm \
  OBJCOPY=llvm-objcopy \
  OBJDUMP=llvm-objdump \
  STRIP=llvm-strip

end=$(date +%s)

runtime=$((end-start))

echo "======================================"
echo "Build Finished"
echo "Threads Used : $THREADS"
echo "Time Taken   : $(($runtime / 60)) min $(($runtime % 60)) sec"
echo "======================================"

if [ -f out/arch/arm64/boot/Image.gz-dtb ]; then
    echo "Kernel Image: out/arch/arm64/boot/Image.gz-dtb"
elif [ -f out/arch/arm64/boot/Image.gz ]; then
    echo "Kernel Image: out/arch/arm64/boot/Image.gz"
else
    echo "Kernel build finished but image not found."
fi
