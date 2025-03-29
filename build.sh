#!/bin/sh

NPROCESSORS="$(getconf NPROCESSORS_ONLN 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null)"

cd openssl || exit 1

env \
  AR="/home/x33f3/wasi-sdk-25.0-x86_64-linux/bin/llvm-ar" \
  RANLIB="/home/x33f3/wasi-sdk-25.0-x86_64-linux/bin/llvm-ranlib" \
  CC="/home/x33f3/wasi-sdk-25.0-x86_64-linux/bin/clang \
      --target=wasm32-wasi \
      --sysroot=/home/x33f3/wasi-sdk-25.0-x86_64-linux/share/wasi-sysroot" \
  CFLAGS="-O3 -ffast-math -Werror -Qunused-arguments -Wno-shift-count-overflow \
          -matomics -mbulk-memory -pthread -mthread-model posix" \
  CPPFLAGS="$CPPFLAGS \
            -D_BSD_SOURCE \
            -D_WASI_EMULATED_GETPID \
            -Dgetuid=getpagesize \
            -Dgeteuid=getpagesize \
            -Dgetgid=getpagesize \
            -Dgetegid=getpagesize" \
  CXXFLAGS="-Werror -Qunused-arguments -Wno-shift-count-overflow \
            -matomics -mbulk-memory -pthread -mthread-model posix" \
  LDFLAGS="-lwasi-emulated-getpid \
           -Wl,--shared-memory \
           -Wl,--max-memory=4294967296 \
           -Wl,--import-memory \
           -Wl,--export-dynamic" \
  ./Configure \
    --banner="wasm32-wasi port" \
    no-asm \
    no-async \
    no-egd \
    no-ktls \
    no-module \
    no-posix-io \
    no-secure-memory \
    no-shared \
    no-sock \
    no-stdio \
    no-thread-pool \
    no-threads \
    no-ui-console \
    no-weak-ssl-ciphers \
    wasm32-wasi || exit 1

make "-j${NPROCESSORS}"

cd - || exit 1

mkdir -p precompiled/lib
mv openssl/*.a precompiled/lib

mkdir -p precompiled/include
cp -r openssl/include/openssl precompiled/include
