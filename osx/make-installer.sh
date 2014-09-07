#!/bin/bash

# Retrieve latest source code without any history
git clone --depth 1 https://github.com/Mudlet/Mudlet.git source

# In case it already exists, update it
cd source/
git pull

# Setup PATH to find qmake
PATH=~/Qt5.3.1/5.3/clang_64/bin:$PATH

# Compile
cd src/
qmake
make -j 2
