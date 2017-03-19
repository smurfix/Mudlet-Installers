The OS X installer generation
=============================

The directory
-------------

This directory contains all files needed to create the OS X installer. It is home to two helper scripts `build-and-make-installer.sh`, which runs the full build and generation process, as well as `make-installer.sh`, which is the isolated generation process.

The `appdmg` directory houses all files needed to create the final installer image, which has the OS X `dmg` format.

Prerequisites
-------------

The scripts update and install most dependencies themselves. But there are a few tools expected to be available:

- `brew`
- `Xcode`
- `git`

How to generate the installer
-----------------------------

### Building and generating in one step ###

Usage:
```bash
./build-and-make-installer.sh [<commit-ish>]
```

Example:
```bash
./build-and-make-installer.sh development
```

The script `build-and-make-installer.sh` installs build dependencies, clones  the git repository of Mudlet, checks the specified `commit-ish`out of the repository and starts building Mudlet. This may take a while. After the build is done, it hands control to the `make-installer.sh` script automatically.

If an `source` subdirectory exists, `commit-ish` is optional. If it exists, the currently checked out branch is used to build, otherwise the Mudlet sources will be cloned into the `source` subdirectory and `commit-ish` will be checked out.

### Generating the installer only ###

Usage:
```bash
./make-installer.sh
```

Prerequisites:

- A pre-build `Mudlet.app` bundle in `./source/build/`, e.g. the output of the Travis build process or the result of the `build-and-make-installer.sh` before it hands control to this script.

The script `make-installer.sh` installs all run-time dependencies of Mudlet, copies them as well as Qt required dynamically linked libraries into the `Mudlet.app` bundle, adapts search pathes and finally bundles it all up into a single installable `Mudlet.dmg`.

The script will ask for the `sudo` password to install required `luarocks` libraries.