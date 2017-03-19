#!/bin/bash

# abort script if any command fails
set -e

# extract program name for message
pgm=$(basename "$0")

# Retrieve latest source code, keep history as it's useful to edit sometimes
# if it's already there, keep it as is
if [ ! -d "source" ]; then
  # check command line option for commit-ish that should be checked out
  commitish="$1"
  if [ -z "$commitish" ]; then
    echo "No 'source' folder exists and no commit-ish given."
    echo "Usage: $pgm <commit-ish>"
    exit 2
  fi

  git clone https://github.com/Mudlet/Mudlet.git source

  # Switch to $commitish
  (cd source && git checkout $commitish)
fi

# set the commit ID so the build can reference it later
cd source
commit=$(git rev-parse --short HEAD)

#install dependencies to compile mudlet
CI/travis.osx.before_install.sh
CI/travis.osx.install.sh

# Setup PATH to find qmake
PATH=/usr/local/opt/qt5/bin:$PATH

# Add commit information to version
cd src/
perl -pi -e "s/BUILD = -dev.*$/BUILD = -dev-$commit/" src.pro
cd ..

mkdir -p build
cd build/
# Remove old Mudlet.app, as macdeployqt doesn't like re-doing things otherwise.
rm -rf Mudlet.app/

# Compile using all available cores
qmake ../src/src.pro
make -j `sysctl -n hw.ncpu`

# now run the actual installer creation script
cd ../..
./make-installer.sh
