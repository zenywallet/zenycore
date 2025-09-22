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
    exec "DEBUG_LEVEL=0 make -j$(nproc) liblz4.a"
    exec "CFLAGS=-Wno-error CPLUS_INCLUDE_PATH=./$(basename lz4-*/)/lib ROCKSDB_DISABLE_SNAPPY=1 ROCKSDB_DISABLE_ZLIB=1 ROCKSDB_DISABLE_BZIP=1 ROCKSDB_DISABLE_ZSTD=1 make -j$(nproc) static_lib"
    exec "mkdir -p ../../src/zenycore/deps/rocksdb"
    exec "cp librocksdb.a ../../src/zenycore/deps/rocksdb/"
    exec "cp liblz4.a ../../src/zenycore/deps/rocksdb/"

task rocksdbDefault, "Build RocksDB (Default)":
  withDir "deps/rocksdb":
    exec "make clean"
    exec "DEBUG_LEVEL=0 make -j$(nproc) libsnappy.a"
    exec "CFLAGS=-Wno-error ROCKSDB_DISABLE_LZ4=1 ROCKSDB_DISABLE_ZLIB=1 ROCKSDB_DISABLE_BZIP=1 ROCKSDB_DISABLE_ZSTD=1 make -j$(nproc) static_lib"
    exec "mkdir -p ../../src/zenycore/deps/rocksdb"
    exec "cp librocksdb.a ../../src/zenycore/deps/rocksdb/"
    exec "cp libsnappy.a ../../src/zenycore/deps/rocksdb/"


before install:
  if not fileExists("src/zenycore/deps/rocksdb/librocksdb.a"):
    rocksdbTask()
