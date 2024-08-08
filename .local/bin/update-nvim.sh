#! /bin/bash


INSTALL_ARCHIVE=nvim-linux64.tar.gz
RELEASE_URL=$(wget -q -O - https://api.github.com/repos/neovim/neovim/releases/latest | grep "download\/v\(.*\)\/${INSTALL_ARCHIVE}" | head -n 1 | cut -d : -f 2,3 | tr -d \")
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

if [ ${INSTALLED_VERSION} == ${RELEASE_VERSION} ]; then
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
    if [ $? != 0 ]; then
      echo Error downloading from ${RELEASE_URL}
      rm ${INSTALL_ARCHIVE}
      exit -1
    fi
    REMOVE_ARCHIVE="yes"
  fi 
fi

if [ "$EUID" -ne 0 ]; then
  echo Please run as root
  exit -1
fi

tar xf ${INSTALL_ARCHIVE}
if [ ! -d "./nvim-linux64/" ]; then
  echo Missing ./nvim-linux64/ after unarchival. Please check ${INSTALL_ARCHIVE}.
  exit -1
fi 

cp -rf ./nvim-linux64/bin/nvim /usr/bin/
cp -rf ./nvim-linux64/lib/nvim /usr/lib/
cp -rf ./nvim-linux64/share/nvim     /usr/share
cp -rf ./nvim-linux64/share/icons/*  /usr/share/icons/
cp -rf ./nvim-linux64/share/locale/* /usr/share/locale/
cp -rf ./nvim-linux64/man/*          /usr/share/man/

rm -rf ./nvim-linux64

if [ -x /usr/bin/update-alternatives ]; then
  update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
  update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
fi 

if [ "${REMOVE_ARCHIVE}" == "yes" ]; then
  rm ${INSTALL_ARCHIVE}
fi

exit 0
