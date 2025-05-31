#!/bin/bash
set -e

# Ganti path ini sesuai dengan struktur proyek
export LFS=~/projectx/lfs/g-distro/lfs

# Buat folder
mkdir -pv $LFS/{sources,tools}
chmod -v a+wt $LFS/sources

# Buat symlink /tools jika belum ada
if [ ! -L /tools ]; then
  sudo ln -sv $LFS/tools /tools
fi

# Tambah user lfs jika belum ada
if ! id lfs &>/dev/null; then
  sudo useradd -s /bin/bash -g users -m -k /dev/null lfs
  echo "Set password untuk user lfs"
  sudo passwd lfs
fi

# Set ownership
sudo chown -vR lfs $LFS/{sources,tools}

# Buat bash profile untuk user lfs
sudo -u lfs bash -c 'cat > ~/.bash_profile << EOF
exec env -i HOME=$HOME TERM=$TERM PS1="\\u:\\w$ " /bin/bash
EOF'

sudo -u lfs bash -c 'cat > ~/.bashrc << EOF
set +h
umask 022
LFS=$LFS
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/tools/bin:/bin:/usr/bin
export LFS LC_ALL LFS_TGT PATH
EOF'

echo "✅ Environment LFS berhasil disiapkan. Jalankan: su - lfs"
