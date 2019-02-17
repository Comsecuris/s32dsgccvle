FROM debian:stretch
ENV TZ=Europe/Berlin
ENV DEBIAN_FRONTEND=noninteractive
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get upgrade -y && apt-get install -y build-essential gcc-multilib g++-multilib
RUN apt-get install -y wget sudo less vim-tiny
# Add user
RUN useradd -c 'User' -G sudo -m -g users user

# Don't require password for sudo
RUN perl -i -pe 's/(%sudo.*) ALL/\1 NOPASSWD: ALL/' /etc/sudoers

USER user
# we have to explicitly set this environment variable
ENV HOME=/home/user
WORKDIR ${HOME}

#RUN wget https://www.nxp.com/lgfiles/updates/S32DS/S32DS_PA_2017.R1_GCC.tar
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

# install build dependencies for toolchain build
RUN sudo apt-get install -y zlib1g-dev autoconf autogen bison flex gettext libtool-bin m4 expect dejagnu texinfo automake tcl-dev file
RUN sudo apt-get install -y texlive libgmp-dev libmpfr-dev libmpc-dev
RUN sudo apt-get install -y screen less

# fix for build.sh using hostname to pick up environment file
RUN perl -i -pe "s/\`hostname\`/${HOSTNAME}/" ${SRCDIR}/build_gnu/build.sh

RUN build.sh s=F494 ELe200
RUN build.sh -s Xbin s=F494 ELe200

# Uh, this is like dangerous if we don't verify checksums thereafter
RUN (cd ${HOME}/build/opt/freescale/ELe200/gcc-4.9.4;contrib/download_prerequisites)
RUN build.sh -s EgccM s=F494 ELe200
RUN build.sh -s newlib s=F494 ELe200
RUN build.sh -s Egcc s=F494 ELe200
RUN build.sh -s tar s=F494 ELe200
