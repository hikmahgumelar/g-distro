#!/bin/bash
set -e

init_rootfs(){
ROOTFS_DIR="rootfs"

mkdir -p "$ROOTFS_DIR"/{bin,boot,dev,etc/init.d,home,lib,lib64,media,mnt,opt,proc,root,run,sbin,srv,sys,tmp,usr/{bin,lib,lib64,sbin,share},var/{log,tmp,lib}}

# Opsional symlink init
ln -sf /sbin/init "$ROOTFS_DIR/init"

echo "[✓] Struktur rootfs berhasil dibuat di: $ROOTFS_DIR/"


}

download_utils(){

SOURCE_DIR="lfs/source"

wget --continue --input-file=wget-minimal.list  --directory-prefix=$SOURCE_DIR
}

#uncomment if you run for first time
#init_rootfs

#run for download utils
#download_utils
