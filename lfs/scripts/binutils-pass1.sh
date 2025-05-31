#!/bin/bash
set -e

export LFS=$(cd ../.. && pwd)/lfs
export LFS_TGT=$(uname -m)-lfs-linux-gnu
export PATH=$LFS/tools/bin:$PATH
echo $LFS
cd $LFS/sources

# Ekstrak
tar -xf binutils-*.tar.*z
cd binutils-*/

# Buat direktori build terpisah
mkdir -v build
cd build

# Konfigurasi awal
../configure \
  --target=$LFS_TGT \
  --prefix=$LFS/tools \
  --with-sysroot \
  --disable-nls \
  --disable-werror

# Kompilasi
make

# Instalasi
make install

# Cleanup
cd ../..
rm -rf binutils-*/

echo "[✓] Binutils Pass 1 selesai."

