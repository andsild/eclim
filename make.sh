#!/usr/bin/env bash

# GENERAL NOTES FOR TROUBLESHOOTING:
# #1 run vim and do :PingEclim and :EclimValidate
# #2 delete ~/.eclipse folder
# #3 try to keep only one instance of elipse alive

# export ECLIM_ECLIPSE_HOME=/nix/store/isimibadhrlxg2vk54l3kjvyym4yccxj-eclipse-platform-4.7.2/eclipse/
# export ECLIM_ECLIPSE_HOME=$(echo $(ls -o "$(ls -o $(which eclipse)/bin/eclipse | sed 's/.*->//; s/bin.*// ; s/^ //')" | grep --color=none share | sed 's/.*->// ; s/^ // ; s#/share##')/eclipse)
# echo $ECLIM_ECLIPSE_HOME
export ECLIM_ECLIPSE_HOME="$(ls -l $(nix-build '<myOverride>' --no-build-output -A myEclipse) | sed 's/.*->//; s/bin.*// ; s/^ // ; s#/share#/#' | grep --color=none platform )/eclipse"
ECLIPSE_VERSION=$(awk -F = '/version/ { print $2 }' $ECLIM_ECLIPSE_HOME/.eclipseproduct)
# PLUGINS_DIR="$(find /nix/store/ -maxdepth 1 -name \*eclipse-plugins -type d)"
PLUGINS_DIR="$(grep --color=none dropins "$(nix-build '<myOverride>' --no-build-output -A myEclipse | sed 's/.*->//; s/bin.*// ; s/^ // ; s#/share#/#' | grep --color=none platform)/etc/eclipse.ini" | sed 's/.*=//')"

echo $ECLIM_ECLIPSE_HOME
echo $ECLIPSE_VERSION
echo $PLUGINS_DIR


ant \
  -Declipse.local=$HOME/.eclipse/org.eclipse.platform_$ECLIPSE_VERSION \
  -Dplugins.dir=$PLUGINS_DIR \
  -Dvim.files=$XDG_CONFIG_HOME/nvim \
  || exit 1

dir=$(find $HOME/.eclipse/org.eclipse.platform_$ECLIPSE_VERSION/plugins/ -name nailgun -type d)
dir="${dir%/*}/bin"

mv -v $dir/ng $dir/ng2
ln -vs $(which ng) $dir/ng
