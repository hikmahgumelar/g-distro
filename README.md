# Struktur Proyek Distro Linux (g-distro)

## 🗂️ Direktori Utama

```
projectx/
├── build.sh              # Script untuk build ISO atau rootfs
├── lfs/                  # Folder untuk proses LFS (Linux From Scratch)
│   ├── build.log         # Log proses build
│   ├── scripts/          # Script LFS (binutils, gcc, glibc, dll)
│   ├── sources/          # Source tarball dari wget-list
│   ├── wget-minimal.list # Daftar minimal package untuk toolchain awal
│   └── tools/            # Toolchain hasil build awal
├── rootfs/               # Hasil akhir root filesystem untuk di-push ke ISO
│   ├── bin/
│   ├── boot/
│   ├── dev/
│   ├── etc/
│   │   └── init.d/
│   ├── home/
│   ├── init -> /sbin/init
│   ├── lib/
│   ├── lib64/
│   ├── media/
│   ├── mnt/
│   ├── opt/
│   ├── proc/
│   ├── root/
│   ├── run/
│   ├── sbin/
│   ├── srv/
│   ├── sys/
│   ├── tmp/
│   ├── usr/
│   │   ├── bin/
│   │   ├── lib/
│   │   ├── lib64/
│   │   ├── sbin/
│   │   └── share/
│   └── var/
│       ├── lib/
│       ├── log/
│       └── tmp/
└── README.md
```

## ✅ Langkah-langkah Build LFS

### 1. Persiapan Sistem Host

* Pastikan distro host punya paket:

  * `gcc`, `g++`, `make`, `gawk`, `tar`, `xz`, `bison`, `perl`, `patch`, `texinfo`, `python3`
* Jalankan: `sudo apt install build-essential gawk texinfo` atau `sudo pacman -S base-devel gawk`

### 2. Setup Environment LFS

#### Script: `lfs-setup.sh`

```bash
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
```

### 3. Download Minimal Package

Gunakan `wget-minimal.list`:

```txt
https://ftp.gnu.org/gnu/binutils/binutils-2.42.tar.xz
https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz
https://ftp.gnu.org/gnu/glibc/glibc-2.39.tar.xz
https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.1.tar.xz
https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz
https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz
https://mirrors.edge.kernel.org/pub/linux/kernel/v6.x/linux-6.7.4.tar.xz
```

Download dengan:

```bash
cd $LFS/sources
wget --continue --input-file=wget-minimal.list --directory-prefix=.
```

### 4. Build Toolchain Awal

#### 🔹 binutils-pass1

* Build assembler & linker mandiri
* Output ke `$LFS/tools`

#### 🔹 gcc-pass1

* Build compiler dasar tanpa glibc

#### 🔹 linux-headers

* Pasang header kernel ke `$LFS/usr/include`

#### 🔹 glibc

* Build libc dasar untuk runtime

#### 🔹 gcc-pass2

* Build compiler final dengan dukungan glibc

---

Selanjutnya chroot ke `$LFS` dan lanjut membangun sistem dasar hingga lengkap (init, bash, coreutils, dsb).

