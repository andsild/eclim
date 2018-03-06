#!/usr/bin/env bash

# GENERAL NOTES FOR TROUBLESHOOTING:
# #1 run vim and do :PingEclim and :EclimValidate
# #2 delete ~/.eclipse folder
# #3 try to keep only one instance of elipse alive

# export ECLIM_ECLIPSE_HOME=/nix/store/isimibadhrlxg2vk54l3kjvyym4yccxj-eclipse-platform-4.7.2/eclipse/
export ECLIM_ECLIPSE_HOME=$(echo $(ls -o "$(ls -o $(which eclipse) | sed 's/.*->//; s/bin.*// ; s/^ //')" | grep --color=none share | sed 's/.*->// ; s/^ // ; s#/share##')/eclipse)
ECLIPSE_VERSION=$(awk -F = '/version/ { print $2 }' $ECLIM_ECLIPSE_HOME/.eclipseproduct)
PLUGINS_DIR="$(find /nix/store/ -maxdepth 1 -name \*eclipse-plugins -type d)"

ant \
  -Declipse.local=/home/andsild/.eclipse/org.eclipse.platform_$ECLIPSE_VERSION \
  -Dplugins.dir=$PLUGINS_DIR \
  -Dvim.files=/home/andsild//.config/nvim # | grep -vE "\[javac\]"

dir=$(find /home/andsild/.eclipse/org.eclipse.platform_$ECLIPSE_VERSION/plugins/ -name nailgun -type d)
dir="${dir%/*}/bin"

mv $dir/ng $dir/ng2
ln -s $(which ng) $dir/ng
