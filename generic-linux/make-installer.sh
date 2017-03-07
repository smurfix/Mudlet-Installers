#!/bin/bash

# abort script if any command fails
set -e

# Retrieve latest source code, keep history as it's useful to edit sometimes
if [ ! -d "source" ]; then
  git clone https://github.com/Mudlet/Mudlet.git source
fi

# get linuxdeployqt. Doesn't seem to have a "latest" url yet
if [[ ! -e linuxdeployqt.AppImage ]]; then
  wget -O linuxdeployqt.AppImage https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage
  chmod +x linuxdeployqt.AppImage
fi

# In case it already exists, update it
cd source/
git pull

# Switch to release banrch
git fetch
git checkout release_30

cd src/

# Compile using all available cores
qmake
make -j `nproc --all`

# move the binary up to the root folder where there's a mudlet.desktop - linuxdeployqt likes them together
cp mudlet ../

# go up to source
cd ../
../linuxdeployqt.AppImage ./mudlet -appimage -always-overwrite

