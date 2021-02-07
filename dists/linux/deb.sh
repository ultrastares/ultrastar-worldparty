#!/bin/bash
version_numeric=$(head -n 1 ../../VERSION)-${1:-1}
version=ultrastar-worldparty_${version_numeric}_amd64
build=dists/linux/$version
build_game=../$build
mkdir $version
cd $version
mkdir -p usr/games usr/share/ultrastar-worldparty usr/share/applications usr/share/icons/hicolor/256x256/apps
cd ..
cp ultrastar-worldparty.desktop $version/usr/share/applications/ultrastar-worldparty.desktop
cd ../atom/linux
./compile.sh ../../.. compile-snap
./compile.sh ../../.. compile-snap-debug
cd ../../../game
cp WorldParty $build_game/usr/games/ultrastar-worldparty
cp WorldPartyDebug $build_game/usr/games/ultrastar-worldparty-debug
cp resources/icons/WorldParty.png $build_game/usr/share/icons/hicolor/256x256/apps/ultrastar-worldparty.png
cp -r avatars covers fonts languages licenses plugins resources sounds themes $build_game/usr/share/ultrastar-worldparty
cd $build_game
mkdir DEBIAN usr/share/ultrastar-worldparty/songs usr/share/ultrastar-worldparty/playlists
echo "Package: ultrastar-worldparty
Version: $version_numeric
Section: games
Priority: optional
Architecture: amd64
Installed-Size: $(du -s usr | cut -f1)
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
