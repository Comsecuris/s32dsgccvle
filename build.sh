#!/bin/sh

download_tarball()
{
	baseurl=$1
	filename=$2

	if [ ! -e $filename ]; then
		wget $baseurl/$filename
	fi

	shasum -c "$filename".sha256 2> /dev/null > /dev/null

	if [ $? -eq 0 ]; then
		echo "SHA-256 for $filename matches."
	else
		echo "SHA-256 for $filename does not match. deleting file."
		rm -f "$filename"
		return 1
	fi
	return 0
}

download_tarball "https://www.nxp.com/lgfiles/updates/S32DS" "S32DS_PA_2017.R1_GCC.tar" || exit 1
download_tarball "ftp://gcc.gnu.org/pub/gcc/infrastructure" "mpfr-2.4.2.tar.bz2" || exit 1
download_tarball "ftp://gcc.gnu.org/pub/gcc/infrastructure" "gmp-4.3.2.tar.bz2" || exit 1
download_tarball "ftp://gcc.gnu.org/pub/gcc/infrastructure" "mpc-0.8.1.tar.gz" || exit 1
download_tarball "ftp://gcc.gnu.org/pub/gcc/infrastructure" "isl-0.12.2.tar.bz2" || exit 1
download_tarball "ftp://gcc.gnu.org/pub/gcc/infrastructure" "cloog-0.18.1.tar.gz" || exit 1

# we need network connectivity for installing packages
docker build --target s32dsgccvle-setup -t s32dsgccvle .
# build container without external network connectivity
docker build --target s32dsgccvle-build --network=none -t s32dsgccvle .
