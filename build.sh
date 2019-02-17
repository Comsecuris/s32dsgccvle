#!/bin/sh

if [ -e "S32DS_PA_2017.R1_GCC.tar" ]; then
	echo "file exists, checking SHA-256 checksum"
	shasum -c  S32DS_PA_2017.R1_GCC.tar.sha256 2> /dev/null > /dev/null
	if [ $? -eq 0 ]; then
		echo "everything is OK"
	else
		echo "file is corrupted, re-downloading source code"
		wget https://www.nxp.com/lgfiles/updates/S32DS/S32DS_PA_2017.R1_GCC.tar
	fi
else
	echo "downloading source code"
	wget https://www.nxp.com/lgfiles/updates/S32DS/S32DS_PA_2017.R1_GCC.tar
fi

docker build -t s32dsgccvle .
docker cp ../src/s32ds/source_release/gcc-4.9.4-Ee200-eabivle-i686-linux-g.tar.bz2 .
