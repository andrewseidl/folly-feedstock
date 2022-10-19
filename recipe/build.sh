#!/usr/bin/env bash

set -ex

# Resolves error: 'scm_timestamping' does not name a type
export CXXFLAGS="$CXXFLAGS -DFOLLY_HAVE_SO_TIMESTAMPING=0"

# Resolves error: expected ')' before 'PRId64'
export CXXFLAGS="$CXXFLAGS -D__STDC_FORMAT_MACROS"

# Resolves error No clock_gettime(3) compatibility wrapper available for this platform.
export CXXFLAGS="$CXXFLAGS -DFOLLY_HAVE_CLOCK_GETTIME=1"

# Resolves error invalid conversion from 'void (*)() noexcept' to 'google::logging_fail_func_t' {aka 'void (*)() __attribute__((noreturn))'}
export CXXFLAGS="$CXXFLAGS -fpermissive"

# Enable sse4.2
export CXXFLAGS="$CXXFLAGS -mavx2 -mfma -mavx -mf16c -mlzcnt -std=c++17 -mbmi2"

mkdir -p _build
cd _build

if [[ ! -z "${folly_build_ext+x}" && "${folly_build_ext}" == "jemalloc" ]]
then
    CMAKE_ARGS="${CMAKE_ARGS} -DENABLE_JEMALLOC=ON"
else
    CMAKE_ARGS="${CMAKE_ARGS} -DENABLE_JEMALLOC=OFF"
fi

cmake ${CMAKE_ARGS} -Wno-dev -GNinja -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON ..

cmake --build . --parallel

cmake --install .

cd ..
