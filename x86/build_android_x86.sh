#!/bin/bash
NDK=/mnt/d/open/developer-tools/linux/android-ndk-r16b
CPU=i686
ARCH=x86
TAGET_ARCH=i686
PREFIX=/mnt/d/source/ffmpeg-n4.0.2-x86/build
TOOLCHAIN=$NDK/build/standalone_toolchain/x86
PLATFORM=$NDK/build/standalone_toolchain/x86/sysroot
ADDI_LDFLAGS=
ADDI_CFLAGS=
function build_ffmpeg
{
./configure \
--prefix=$PREFIX \
--disable-shared \
--enable-yasm \
--enable-static \
--disable-doc \
--disable-ffmpeg \
--disable-ffplay \
--disable-ffprobe \
--disable-symver \
--enable-small \
--disable-armv5te \
--disable-armv6 \
--disable-armv6t2 \
--disable-linux-perf \
--cross-prefix=$TOOLCHAIN/bin/$TAGET_ARCH-linux-android- \
--target-os=linux \
--arch=$ARCH \
--cpu=$CPU \
--enable-cross-compile \
--sysroot=$PLATFORM \
--extra-cflags="$ADDI_CFLAGS" \
--extra-ldflags="$ADDI_LDFLAGS" \
$ADDITIONAL_CONFIGURE_FLAG

make clean
make -j8
make install

$TOOLCHAIN/bin/$TAGET_ARCH-linux-android-ld \
-rpath-link=$PLATFORM/usr/lib \
-L$PLATFORM/usr/lib \
-L$PREFIX/lib \
-soname libffmpeg.so  \
-shared \
-Bsymbolic \
--whole-archive \
--no-undefined -o \
$PREFIX/libffmpeg.so \
    libavcodec/libavcodec.a \
    libavfilter/libavfilter.a \
    libswresample/libswresample.a \
    libavformat/libavformat.a \
    libavutil/libavutil.a \
    libswscale/libswscale.a \
    -lc -lm -lz -ldl -llog --dynamic-linker=/system/bin/linker \
    $TOOLCHAIN/lib/gcc/$TAGET_ARCH-linux-android/4.9.x/libgcc.a \
    
}

ADDI_CFLAGS="-O3 -Wall -pipe \
    -std=c99 \
    -ffast-math \
    -fstrict-aliasing -Werror=strict-aliasing \
    -Wno-psabi -Wa,--noexecstack -march=armv7-a \
    -DANDROID -DNDEBUG -march=atom -msse3 -ffast-math -mfpmath=sse"
build_ffmpeg

