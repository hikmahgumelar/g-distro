# Struktur Proyek Distro Linux (g-distro)

distro ini di peruntukan untuk environtment blockchain, yang di harapkan adalah distro minimalis dapat berjalan dengan baik sebagai blockchain validator ataupun node lainnya.
sehingga resource hanya di prioritaskan untuk blockchain network dan bukan hanya itu, di harapkan distro ini dapat digunakan untuk embeded system.

- Kenapa harus membuat distro baru, misal menggunakan alpine yang sudah minimalis?
  jawabannya: 
  kami membuat distro ini dengan goals lebih minimal dan dari security kami mengharapkan distro yang immutable sehingga tamper data atau pembobolan tidak terjadi di distro ini.
   kami memilih paket yang di gunakan dengan seleksi ketat sampai dependensinya
linux ini menggunakan LFS sebagai base dan 
untuk mencapai itu kami harus lebih extra dengan membuat distro sendiri yang nantinya akan di gunakan di network blockchain EVM Kompatible, Solana 
dan yang lainnya.

untuk Q&A yang lain kami akan buat berbarengan server repo.
dan untuk distro ini package yang tersedia hanya di fokuskan untuk blockchain dengan seleksi ketat dan tentunya tidak ada perubahan dari kami.
tugas kami hanya membangun dan menseleksi paket dengan ketat sampai dependensinya.

dan kami pada tahun 2021 sudah membuat distro untuk ETH validator menggunakan g-distro-alpha yang berjalan di 50 nodes sampai saat ini.
dan telah menjadi validator selama 4 tahun dengan aman dan hanya sekali setup dengan paket manager hanya menggunakan bash script.
untuk paket manager kami coba beralih menggunakan bahasa lain.

distro ini sedang kami coba untuk vpn mysterium sebagai node dan belum ada 1 tahun, dengan pilihan region france menggunakan cpu 1 memory 1Gb 11 nodessudah berjalan 6 di region france dan sisanya kami sebar di beberapa region, untuk saat ini resource di bawah 20% karena vpn mysterium hanya menggunakan network.
walau pendapatan dari membangun node mysterium hanya untuk bayar sewa :) membuktikan g-distro-alpha untuk utilitas resource dan systemnya yang immutable telah membuktikan yang menurut kami dapat di bangun untuk hal lain.
dan kami memutuskan untuk membangun versi g-distro-beta sebelum release.
dan saat ini hanya tim kami yang menseleksi paket-paket.
distro ini sifatnya tidak tertutup hanya tim didalamnya yang tertutup dan introvert akut😂.

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

