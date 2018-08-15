#!/bin/bash
NDK=/mnt/d/open/developer-tools/linux/android-ndk-r16b
CPU=armv7-a
ARCH=arm
TAGET_ARCH=arm
PREFIX=/mnt/d/source/ffmpeg-n4.0.2-armv7/build
TOOLCHAIN=$NDK/build/standalone_toolchain/$CPU
PLATFORM=$NDK/build/standalone_toolchain/$CPU/sysroot
ADDI_LDFLAGS="$ADDI_CFLAGS"
function build_ffmpeg
{
./configure \
--prefix=$PREFIX \
--disable-shared \
--disable-yasm \
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
--cross-prefix=$TOOLCHAIN/bin/$TAGET_ARCH-linux-androideabi- \
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

$TOOLCHAIN/bin/$TAGET_ARCH-linux-androideabi-ld \
-rpath-link=$PLATFORM/usr/lib \
-L$PLATFORM/usr/lib \
-L$PREFIX/lib \
-soname libffmpeg.so \
-nostdlib \
-z noexecstack \
-shared \
-Bsymbolic \
--whole-archive \
--no-undefined \
-o $PREFIX/libffmpeg.so \
    libavcodec/libavcodec.a \
    libavfilter/libavfilter.a \
    libswresample/libswresample.a \
    libavformat/libavformat.a \
    libavutil/libavutil.a \
    libswscale/libswscale.a \
    -lc -lm -lz -ldl -llog --dynamic-linker=/system/bin/linker \
    $TOOLCHAIN/lib/gcc/$TAGET_ARCH-linux-androideabi/4.9.x/libgcc.a \
	
$TOOLCHAIN/bin/$TAGET_ARCH-linux-androideabi-strip $PREFIX/libffmpeg.so
    
}

ADDI_CFLAGS="-O3 -Wall -pipe \
    -std=c99 \
    -ffast-math \
    -fstrict-aliasing -Werror=strict-aliasing \
    -Wno-psabi -Wa,--noexecstack \
	-ffunctipn-sections \
	-fdata-sections \
    -DANDROID -DNDEBUG -Wl,--fix-cortex-a8 --arch=arm -march=armv7-a \
    -mfpu=vfpv3-d16 -mfloat-abi=softfp -mthumb"

ADDI_LDFLAGS=" -Wl,--fix-cortex-a8"
build_ffmpeg
