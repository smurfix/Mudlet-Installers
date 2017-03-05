#!/bin/bash

# abort script if any command fails
set -e

# Retrieve latest source code without any history
if [ ! -d "source" ]; then
  git clone --depth 1 https://github.com/Mudlet/Mudlet.git source
fi

# In case it already exists, update it
cd source/
git pull

# Switch to release banrch
git fetch
git checkout release_30

# Setup PATH to find qmake
PATH=/Users/mudlet/Qt/5.8/clang_64/bin:$PATH

cd src/
# Remove old Mudlet.app, as macdeployqt doesn't like re-doing things otherwise. Requires admin rights.
sudo rm -rf Mudlet.app/

# Compile using all available cores
qmake
make -j `sysctl -n hw.ncpu`

# Bundle in Qt libraries
../../mac-deploy.sh

# Bundle in dynamically loaded libraries
sudo cp ../../lfs.so Mudlet.app/Contents/MacOS
sudo cp ../../rex_pcre.so Mudlet.app/Contents/MacOS
# rex_pcre has to be adjusted to load libcpre from the same location
sudo cp ../../libpcre.1.dylib Mudlet.app/Contents/MacOS
sudo cp -r ../../luasql Mudlet.app/Contents/MacOS

# As well as the loader for them
sudo cp ../../run_mudlet Mudlet.app/Contents/MacOS

# Edit the executable to be run_mudlet instead of Mudlet
/usr/libexec/PlistBuddy -c "Set CFBundleExecutable run_mudlet" Mudlet.app/Contents/Info.plist

# Generate final .dmg
rm ~/Desktop/Mudlet.dmg

# If you don't get a background image on Sierra, either upgrade
# or apply a workaround from https://github.com/LinusU/node-appdmg/issues/121
appdmg ./osx-installer/mudlet-appdmg.json ~/Desktop/Mudlet.dmg
