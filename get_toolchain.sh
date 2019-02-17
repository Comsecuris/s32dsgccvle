#!/bin/sh

TARBALL=gcc-4.9.4-Ee200-eabivle-i686-linux-g.tar.bz2 

docker run --rm s32dsgccvle tar -C ../src/s32ds/source_release -cf - ${TARBALL}|tar -xf -
