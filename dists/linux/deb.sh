#!/bin/bash
if [ $# != 3 ]
then
    echo "Version and size not provided."
    echo "You must add 3 parameters: main_version specific_version size_in_bytes"
    echo "for example: 20.12 1 93396"
    exit
fi
version=ultrastar-worldparty_$1-$2_amd64
build=dists/linux/$version
build_game=../$build
mkdir $version
cd $version
mkdir -p usr/games usr/share/ultrastar-worldparty usr/share/applications usr/share/icons/hicolor/256x256/apps
cd ..
cp ultrastar-worldparty.desktop $version/usr/share/applications/ultrastar-worldparty.desktop
cd ../../game
cp WorldParty $build_game/usr/games/ultrastar-worldparty
cp WorldPartyDebug $build_game/usr/games/ultrastar-worldparty-debug
cp resources/icons/WorldParty.png $build_game/usr/share/icons/hicolor/256x256/apps/ultrastar-worldparty.png
cp -r avatars covers fonts languages plugins resources sounds themes visuals $build_game/usr/share/ultrastar-worldparty
cd $build_game
mkdir DEBIAN
echo "Package: ultrastar-worldparty
Version: 20.12-1
Section: games
Priority: optional
Architecture: amd64
Installed-Size: $3
Depends: libsdl2-image-dev, libavformat-dev, libswscale-dev, libsqlite3-dev, libfreetype6-dev, libportmidi-dev, liblua5.3-dev, libopencv-highgui-dev
Maintainer: TeLiXj <telixj@gmail.com>
Homepage: https://ultrastar-es.org
Description: A free and open source karaoke game
 It allows up to six players to sing along with music using microphones in order to score points, depending on the pitch of the voice and the rhythm of singing.
 Fun singing your favorite songs!" >> DEBIAN/control
cd ..
dpkg-deb --build $version
rm -rf $version
mv *.deb ../..
