No problem — here's the whole thing as one straight line, no choices to make. Everything is decided.

You work on **two machines**: your laptop (has internet + Docker), and the offline server.

---

## PART A — On your laptop

**Step 1.** Make an empty folder and go into it.

```bash
mkdir ~/pybuild && cd ~/pybuild
```

**Step 2.** Create a file named `Dockerfile` with this exact content:

```dockerfile
FROM almalinux:8.9

RUN dnf -y install gcc gcc-c++ make perl-core wget tar findutils \
      zlib-devel bzip2-devel xz-devel libffi-devel \
      sqlite-devel readline-devel ncurses-devel \
      libuuid-devel gdbm-devel && dnf clean all

WORKDIR /build

RUN wget -q https://github.com/openssl/openssl/releases/download/openssl-3.0.18/openssl-3.0.18.tar.gz \
 && tar xf openssl-3.0.18.tar.gz && cd openssl-3.0.18 \
 && ./Configure --prefix=/home/appadmin/python3.14 --libdir=lib \
      --openssldir=/home/appadmin/python3.14/ssl \
      shared zlib "-Wl,-rpath,/home/appadmin/python3.14/lib" \
 && make -j"$(nproc)" && make install_sw install_ssldirs

RUN wget -q https://www.python.org/ftp/python/3.14.6/Python-3.14.6.tgz \
 && tar xf Python-3.14.6.tgz && cd Python-3.14.6 \
 && ./configure \
      --prefix=/home/appadmin/python3.14 \
      --with-openssl=/home/appadmin/python3.14 \
      --with-openssl-rpath=auto \
      --enable-optimizations \
      --with-ensurepip=install \
      LDFLAGS="-Wl,-rpath,/home/appadmin/python3.14/lib" \
 && make -j"$(nproc)" && make install

RUN /home/appadmin/python3.14/bin/python3 -c "import ssl,sqlite3,lzma,bz2,ctypes,readline,zlib; print(ssl.OPENSSL_VERSION)" \
 && tar -czf /python-bundle.tar.gz -C /home/appadmin python3.14
```

**Step 3.** Build it. Takes 15–25 minutes.

```bash
docker build --platform linux/amd64 -t pybuild .
```

**Step 4.** Pull the tarball out.

```bash
docker create --name tmp pybuild
docker cp tmp:/python-bundle.tar.gz .
docker rm tmp
ls -lh python-bundle.tar.gz
```

**Step 5.** Copy `python-bundle.tar.gz` to the offline server (USB or however you normally move files).

---

## PART B — On the offline server

**Step 6.** Extract it into your home directory.

```bash
cd /home/appadmin
tar -xzf python-bundle.tar.gz
```

**Step 7.** Verify.

```bash
~/python3.14/bin/python3 -V
~/python3.14/bin/python3 -c "import ssl,sqlite3,lzma,ctypes; print(ssl.OPENSSL_VERSION)"
```

Expected: `Python 3.14.6` and `OpenSSL 3.0.18 ...`. If both print, you're done.

**Step 8.** Add it to your PATH and clean up.

```bash
echo 'export PATH="$HOME/python3.14/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
rm -f ~/python-bundle.tar.gz
python3 -V
```

---

That's it. I dropped the `requirements.txt` part entirely — get the interpreter working first, then come back and we'll add your libraries as a second pass.

Two rules that matter: don't change the path `/home/appadmin/python3.14` anywhere (it's compiled into the binary), and don't touch `/usr/bin/python3` (RHEL's own tools run on it).