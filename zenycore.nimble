# Package

version       = "0.1.0"
author        = "zenywallet"
description   = "A core and libraries for BitZeny"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
installDirs   = @["zenycore/deps"]
bin           = @["zenycore"]


# Dependencies

requires "nim >= 2.2.4"


# Tasks

task rocksdb, "Build RocksDB":
  withDir "deps/rocksdb":
    exec "make clean"
    exec "DEBUG_LEVEL=0 make -j$(nproc --all || sysctl -n hw.ncpu || getconf _NPROCESSORS_ONLN || echo 1) liblz4.a"
    exec "CFLAGS=-Wno-error CPLUS_INCLUDE_PATH=./$(basename lz4-*/)/lib ROCKSDB_DISABLE_SNAPPY=1 ROCKSDB_DISABLE_ZLIB=1 ROCKSDB_DISABLE_BZIP=1 ROCKSDB_DISABLE_ZSTD=1 make -j$(nproc --all || sysctl -n hw.ncpu || getconf _NPROCESSORS_ONLN || echo 1) static_lib"
    exec "mkdir -p ../../src/zenycore/deps/rocksdb"
    exec "cp -a librocksdb.a ../../src/zenycore/deps/rocksdb/"
    exec "cp -a liblz4.a ../../src/zenycore/deps/rocksdb/"

task rocksdbDefault, "Build RocksDB (Default)":
  withDir "deps/rocksdb":
    exec "make clean"
    exec "DEBUG_LEVEL=0 make -j$(nproc --all || sysctl -n hw.ncpu || getconf _NPROCESSORS_ONLN || echo 1) libsnappy.a"
    exec "CFLAGS=-Wno-error ROCKSDB_DISABLE_LZ4=1 ROCKSDB_DISABLE_ZLIB=1 ROCKSDB_DISABLE_BZIP=1 ROCKSDB_DISABLE_ZSTD=1 make -j$(nproc --all || sysctl -n hw.ncpu || getconf _NPROCESSORS_ONLN || echo 1) static_lib"
    exec "mkdir -p ../../src/zenycore/deps/rocksdb"
    exec "cp -a librocksdb.a ../../src/zenycore/deps/rocksdb/"
    exec "cp -a libsnappy.a ../../src/zenycore/deps/rocksdb/"

import std/os
import std/strutils

task sophia, "Build Sophia":
  withDir "deps/sophia":
    var ss_lz4filter = "sophia/std/ss_lz4filter.c"
    exec "git checkout " & ss_lz4filter
    var s = readFile(ss_lz4filter)
    s = s.replace("LZ4", "ss_LZ4")
    s = s.replace("XXH32", "ss_XXH32")
    s = s.replace("XXH64", "ss_XXH64")
    writeFile(ss_lz4filter, s)
    exec "make -j$(nproc --all || sysctl -n hw.ncpu || getconf _NPROCESSORS_ONLN || echo 1)"
    exec "mkdir -p ../../src/zenycore/deps/sophia"
    exec "cp -a libsophia.a ../../src/zenycore/deps/sophia/"

task duckdb, "Build DuckDB":
  withDir "deps/duckdb":
    exec "make clean"
    exec "make -j$(nproc --all || sysctl -n hw.ncpu || getconf _NPROCESSORS_ONLN || echo 1) bundle-library"
    exec "mkdir -p ../../src/zenycore/deps/duckdb"
    exec "cp -a build/release/libduckdb_bundle.a ../../src/zenycore/deps/duckdb/"
    exec "cp -a build/release/src/libduckdb.so ../../src/zenycore/deps/duckdb/"


before install:
  if not fileExists("src/zenycore/deps/rocksdb/librocksdb.a"):
    rocksdbTask()
  if not fileExists("src/zenycore/deps/sophia/libsophia.a"):
    sophiaTask()
  if not fileExists("src/zenycore/deps/duckdb/libduckdb.so"):
    duckdbTask()
