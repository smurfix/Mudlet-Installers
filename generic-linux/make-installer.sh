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

# go up to the root folder and clean up the build/ folder
cd ../../
rm -rf build/
mkdir build

# delete previous appimage as well since we need to regenerate it twice
rm Mudlet*.AppImage

# move the binary up to the build folder
cp source/src/mudlet build/
# get mudlet-lua in there as well so linuxdeployqt bundles it
cp -rf source/src/mudlet-lua build/
# and the .desktop file so linuxdeployqt can pilfer it for info
cp source/mudlet{.desktop,.png,.svg} build/

# first go at generation
echo "Generating AppImage for the first time"
./linuxdeployqt.AppImage ./build/mudlet -appimage

# now copy Lua modules we need in
# this should be improved not to be hardcoded
cp /usr/lib/x86_64-linux-gnu/lua/5.1/lfs.so      ./build/lib
cp /usr/lib/x86_64-linux-gnu/lua/5.1/rex_pcre.so ./build/lib
mkdir ./build/lib/luasql
cp /usr/lib/x86_64-linux-gnu/lua/5.1/luasql/sqlite3.so ./build/lib/luasql
cp /usr/lib/x86_64-linux-gnu/lua/5.1/zip.so      ./build/lib

echo "Regenerating AppImage to include Lua C modules"
# and regenerate (https://github.com/probonopd/linuxdeployqt/issues/67#issuecomment-279211530)
./linuxdeployqt.AppImage ./build/mudlet -appimage
