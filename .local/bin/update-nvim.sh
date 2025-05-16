#! /bin/bash

if [ "$EUID" -ne 0 ]; then
  echo Please run as root
  exit -1
fi

INSTALL_ARCHIVE=nvim-linux64.tar.gz
RELEASE_URL=$(wget -q -O - https://api.github.com/repos/neovim/neovim/releases/latest | jq -r '.assets[] | select(.name=="nvim-linux-x86_64.tar.gz").browser_download_url')
RELEASE_VERSION=$(echo $RELEASE_URL | cut -d \/ -f 8)

if [ -x /usr/bin/nvim ]; then
  INSTALLED_VERSION=$(nvim --version | head -n 1 | cut -d' ' -f 2)
else
  INSTALLED_VERSION='v0.0.0'
fi

REMOVE_ARCHIVE="no"

if [ ! -z "$1" ]; then
  RELEASE_VERSION="$1"
  RELEASE_URL="https://github.com/neovim/neovim/releases/download/$1/${INSTALL_ARCHIVE}"
fi

if [ "${INSTALLED_VERSION}" == "${RELEASE_VERSION}" ]; then
  echo Latest version already installed. 
  echo Please run this script in folder containing ${INSTALL_ARCHIVE}, or with a release tag to download a release.
  echo 
  echo $0 nightly \# to download the latest nightly build.
  exit -1
else
  echo Latest release version    = ${RELEASE_VERSION}
  echo Current installed version = ${INSTALLED_VERSION}

  if [ ! -e ${INSTALL_ARCHIVE} ]; then
    wget -q --show-progress -O ${INSTALL_ARCHIVE} ${RELEASE_URL}
    WGET_RET=$?
    if [ $WGET_RET != 0 ]; then
      echo Error $WGET_RET downloading from ${RELEASE_URL}
      rm ${INSTALL_ARCHIVE}
      exit -1
    fi
    REMOVE_ARCHIVE="yes"
  fi 
fi

tar xf ${INSTALL_ARCHIVE}
OUTDIR="./nvim-linux-x86_64"
if [ ! -d "${OUTDIR}" ]; then
  echo Missing ./nvim-linux64/ after unarchival. Please check ${INSTALL_ARCHIVE}.
  exit -1
fi 

cp -rf ${OUTDIR}/bin/nvim /usr/bin/
cp -rf ${OUTDIR}/lib/nvim /usr/lib/
cp -rf ${OUTDIR}/share/nvim     /usr/share
cp -rf ${OUTDIR}/share/icons/*  /usr/share/icons/
cp -rf ${OUTDIR}/share/locale/* /usr/share/locale/
cp -rf ${OUTDIR}/man/*          /usr/share/man/

rm -rf ${OUTDIR}

if [ -x /usr/bin/update-alternatives ]; then
  update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
  update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
fi 

if [ "${REMOVE_ARCHIVE}" == "yes" ]; then
  rm ${INSTALL_ARCHIVE}
fi

exit 0
