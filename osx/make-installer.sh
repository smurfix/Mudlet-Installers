#!/bin/bash

# Retrieve latest source code without any history
git clone https://github.com/Mudlet/Mudlet.git source

# In case it already exists, update it
cd source/
git pull

# Switch to release banrch
git fetch
git checkout release_30

# Setup PATH to find qmake
PATH=~/Qt5.3.1/5.3/clang_64/bin:$PATH

cd src/
# Remove old Mudlet.app, as macdeployqt doesn't like re-doing things otherwise. Requires admin rights.
sudo rm -rf Mudlet.app/

# Compile using all available cores
qmake
make -j `sysctl -n hw.ncpu`

# Bundle in Qt libraries
./mac-deploy.sh

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
appdmg ./osx-installer/mudlet-appdmg.json ~/Desktop/Mudlet.dmg