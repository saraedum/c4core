#!/usr/bin/env bash

set -e
set -x

pwd
C4CORE_DIR=$(pwd)

export CC_=$(echo "$CXX_" | sed 's:clang++:clang:g' | sed 's:g++:gcc:g')

if   [ "$LINT" == "all"        ] ; then CMFLAGS="$CMFLAGS -DC4CORE_LINT=ON -DC4CORE_LINT_TESTS=ON -DC4CORE_LINT_CLANG_TIDY=ON  -DC4CORE_LINT_PVS_STUDIO=ON"
elif [ "$LINT" == "clang-tidy" ] ; then CMFLAGS="$CMFLAGS -DC4CORE_LINT=ON -DC4CORE_LINT_TESTS=ON -DC4CORE_LINT_CLANG_TIDY=ON  -DC4CORE_LINT_PVS_STUDIO=OFF"
elif [ "$LINT" == "pvs-studio" ] ; then CMFLAGS="$CMFLAGS -DC4CORE_LINT=ON -DC4CORE_LINT_TESTS=ON -DC4CORE_LINT_CLANG_TIDY=OFF -DC4CORE_LINT_PVS_STUDIO=ON"
else
    CMFLAGS="$CMFLAGS -DC4CORE_LINT=OFF"
fi

if   [ "$SAN" == "ALL" ] ; then CMFLAGS="$CMFLAGS -DC4CORE_SANITIZE=ON"
elif [ "$SAN" == "A"   ] ; then CMFLAGS="$CMFLAGS -DC4CORE_SANITIZE=ON -DC4CORE_ASAN=ON  -DC4CORE_TSAN=OFF -DC4CORE_MSAN=OFF -DC4CORE_UBSAN=OFF"
elif [ "$SAN" == "T"   ] ; then CMFLAGS="$CMFLAGS -DC4CORE_SANITIZE=ON -DC4CORE_ASAN=OFF -DC4CORE_TSAN=ON  -DC4CORE_MSAN=OFF -DC4CORE_UBSAN=OFF"
elif [ "$SAN" == "M"   ] ; then CMFLAGS="$CMFLAGS -DC4CORE_SANITIZE=ON -DC4CORE_ASAN=OFF -DC4CORE_TSAN=OFF -DC4CORE_MSAN=ON  -DC4CORE_UBSAN=OFF"
elif [ "$SAN" == "UB"  ] ; then CMFLAGS="$CMFLAGS -DC4CORE_SANITIZE=ON -DC4CORE_ASAN=OFF -DC4CORE_TSAN=OFF -DC4CORE_MSAN=OFF -DC4CORE_UBSAN=ON"
else
    CMFLAGS="$CMFLAGS -DC4CORE_SANITIZE=OFF"
fi

if [ "$SAN_ONLY" == "ON" ] ; then
    CMFLAGS="$CMFLAGS -DC4CORE_SANITIZE_ONLY=ON"
else
    CMFLAGS="$CMFLAGS -DC4CORE_SANITIZE_ONLY=OFF"
fi

if [ "$VG" == "ON" ] ; then
    CMFLAGS="$CMFLAGS -DC4CORE_VALGRIND=ON -DC4CORE_VALGRIND_SGCHECK=OFF" # FIXME SGCHECK should be ON
elif [ "$VG" == "OFF" ] ; then
    CMFLAGS="$CMFLAGS -DC4CORE_VALGRIND=OFF -DC4CORE_VALGRIND_SGCHECK=OFF"
fi

if [ "$BM" == "ON" ] ; then
    CMFLAGS="$CMFLAGS -DC4CORE_BUILD_BENCHMARKS=ON"
elif [ "$BM" == "OFF" ] || [ "$BM" == "" ] ; then
    CMFLAGS="$CMFLAGS -DC4CORE_BUILD_BENCHMARKS=OFF"
fi

if [ ! -z "$CMFLAGS" ] ; then
    echo "additional cmake flags: $CMFLAGS"
fi

CFLAGS_="-std=c99"
XFLAGS_="-std=c++11"
if [ "$A" == "32" ] ; then
    CFLAGS_="$CFLAGS_ -m32"
    XFLAGS_="$XFLAGS_ -m32"
fi

mkdir build
cd build
cmake -DCMAKE_C_COMPILER=$CC_ -DCMAKE_C_FLAGS="$CFLAGS_" \
      -DCMAKE_CXX_COMPILER=$CXX_ -DCMAKE_CXX_FLAGS="$XFLAGS_" \
      -DCMAKE_BUILD_TYPE=$BT \
      -DC4CORE_DEV=ON \
      $CMFLAGS \
      $C4CORE_DIR
make help | sed 1d | sort
make CTEST_OUTPUT_ON_FAILURE=1 ryml-test
cd -

exit 0
