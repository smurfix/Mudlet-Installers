#!/bin/bash

# abort script if any command fails
set -e

# set path to find macdeployqt
PATH=/usr/local/opt/qt5/bin:$PATH

cd source/build

# get the app to package
app=$(ls -d *.app)

# install installer dependencies
brew update
BREWS="sqlite3 lua@5.1 node wget"
for i in $BREWS; do
  brew outdated | grep -q $i && brew upgrade $i
done
for i in $BREWS; do
  brew list | grep -q $i || brew install $i
done
if [ ! -f "macdeployqtfix.py" ]; then
  wget https://raw.githubusercontent.com/aurelien-rainone/macdeployqtfix/master/macdeployqtfix.py
fi
luarocks-5.1 --local install LuaFileSystem
luarocks-5.1 --local install lrexlib-pcre
luarocks-5.1 --local install LuaSQL-SQLite3 SQLITE_DIR=/usr/local/opt/sqlite

macOsVersion=$(sw_vers -productVersion)
if [ "${macOsVersion}" = "10.12" -o "${macOsVersion}" = "10.12.1" -o "${macOsVersion}" = "10.12.2" ]; then
  npm install -g ArmorText/node-appdmg#feature/background-hack
else
  npm install -g appdmg
fi

# Bundle in Qt libraries
macdeployqt ${app}

# fix unfinished deployment of macdeployqt
python macdeployqtfix.py ${app}/Contents/MacOS/Mudlet /usr/local/Cellar/qt5/5.8.0_1/

# Bundle in dynamically loaded libraries
cp "${HOME}/.luarocks/lib/lua/5.1/lfs.so" ${app}/Contents/MacOS
cp "${HOME}/.luarocks/lib/lua/5.1/rex_pcre.so" ${app}/Contents/MacOS
# rex_pcre has to be adjusted to load libcpre from the same location
python macdeployqtfix.py ${app}/Contents/MacOS/rex_pcre.so /usr/local/Cellar/qt5/5.8.0_1/
cp -r "${HOME}/.luarocks/lib/lua/5.1/luasql" ${app}/Contents/MacOS

# Edit some nice plist entries, don't fail if entries already exist
/usr/libexec/PlistBuddy -c "Add CFBundleName string Mudlet" ${app}/Contents/Info.plist || true
/usr/libexec/PlistBuddy -c "Add CFBundleDisplayName string Mudlet" ${app}/Contents/Info.plist || true

# Generate final .dmg
cd ../..
rm -f ~/Desktop/Mudlet*.dmg

# Modify appdmg config file according to the app file to package
perl -pi -e "s/Mudlet.*\\.app/${app}/" appdmg/mudlet-appdmg.json

# Last: build *.dmg file
appdmg appdmg/mudlet-appdmg.json ~/Desktop/${app%.*}.dmg
