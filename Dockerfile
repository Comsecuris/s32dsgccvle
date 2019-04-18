FROM debian:stretch as s32dsgccvle-setup
ENV TZ=Europe/Berlin
ENV DEBIAN_FRONTEND=noninteractive
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get upgrade -y && apt-get install -y build-essential gcc-multilib g++-multilib
RUN apt-get install -y wget sudo less vim-tiny
# Add user
RUN useradd -c 'User' -G sudo -m -g users user

# Don't require password for sudo
RUN perl -i -pe 's/(%sudo.*) ALL/\1 NOPASSWD: ALL/' /etc/sudoers

# install build dependencies for toolchain build
RUN apt-get install -y zlib1g-dev autoconf autogen bison flex gettext libtool-bin m4 expect dejagnu texinfo automake tcl-dev file
RUN apt-get install -y texlive libgmp-dev libmpfr-dev libmpc-dev
RUN dpkg --add-architecture i386 && apt-get update && \
    apt-get install -y libncurses-dev:i386 zlib1g-dev:i386 libpython-dev:i386

USER user
# we have to explicitly set this environment variable
ENV HOME=/home/user
WORKDIR ${HOME}

FROM s32dsgccvle-setup as s32dsgccvle-build
COPY S32DS_PA_2017.R1_GCC.tar /home/user/S32DS_PA_2017.R1_GCC.tar

RUN mkdir -p src/s32ds bin build
WORKDIR src/s32ds

ENV SRCDIR=${HOME}/src/s32ds/source_release

RUN tar -xf ~/S32DS_PA_2017.R1_GCC.tar

WORKDIR ${HOME}/bin
RUN ln -s ${SRCDIR}/build_gnu/build.sh .

ENV HOSTNAME=s32dsgccvle

RUN echo "REPODIR=${SRCDIR}" > build.env-${HOSTNAME} && \
    echo "RELEASEDIR=${SRCDIR}" >> build.env-${HOSTNAME} && \
    echo "NJOBS=\"-j 16\"" >> build.env-${HOSTNAME} && \
    echo "export PATH=${SRCDIR}/fake_32bit_tools:${HOME}/bin:$PATH" >> build.env-${HOSTNAME}

WORKDIR ${HOME}/build

ENV PATH=${PATH}:$HOME/bin


# fix for build.sh using hostname to pick up environment file
RUN perl -i -pe "s/\`hostname\`/${HOSTNAME}/" ${SRCDIR}/build_gnu/build.sh

RUN build.sh s=F494 ELe200
RUN build.sh -s Xbin s=F494 ELe200

# This download script doesn't do any verification of the downloaded files. Screw that!
RUN perl -i -pe 's/wget/#wget/' "opt/freescale/ELe200/gcc-4.9.4/contrib/download_prerequisites"
COPY cloog-0.18.1.tar.gz gmp-4.3.2.tar.bz2 isl-0.12.2.tar.bz2 \
     mpc-0.8.1.tar.gz mpfr-2.4.2.tar.bz2 \
     opt/freescale/ELe200/gcc-4.9.4/
RUN (cd opt/freescale/ELe200/gcc-4.9.4;contrib/download_prerequisites)

RUN build.sh -s EgccM s=F494 ELe200
RUN build.sh -s newlib s=F494 ELe200
RUN build.sh -s Egcc s=F494 ELe200

# the fallthrough attribute only works with GCC 7.x onwards. We don't build with gcc 7.x, ffs!
RUN grep -lr '__attribute__ *((fallthrough))' opt/freescale/ELe200/src_gdb|xargs perl -i -pe 's/ __attribute__\s*\(\(fallthrough\)\);//'
# we want to have our gdb with python enabled.
RUN build.sh -s EgdbPy s=F494 ELe200
# bundle it up
RUN build.sh -s tar s=F494 ELe200
