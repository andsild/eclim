#!/usr/bin/env bash

# GENERAL NOTES FOR TROUBLESHOOTING:
# #1 run vim and do :PingEclim and :EclimValidate
# #2 delete ~/.eclipse ~/.eclim and your workspace folder

if [ -d "/opt/eclipse" ]
then
  export ECLIM_ECLIPSE_HOME="/opt/eclipse/"
  ECLIPSE_VERSION=$(awk -F = '/version/ { print $2 }' $ECLIM_ECLIPSE_HOME/.eclipseproduct)
  PLUGINS_DIR="/opt/eclipse/plugins/"
else # nixos?
  export ECLIM_ECLIPSE_HOME="$(ls -l $(nix-build '<myOverride>' --no-build-output -A myEclipse) | sed 's/.*->//; s/bin.*// ; s/^ // ; s#/share#/#' | grep --color=none platform )/eclipse"
  ECLIPSE_VERSION=$(awk -F = '/version/ { print $2 }' $ECLIM_ECLIPSE_HOME/.eclipseproduct)
  PLUGINS_DIR="$(grep --color=none dropins "$(nix-build '<myOverride>' --no-build-output -A myEclipse | sed 's/.*->//; s/bin.*// ; s/^ // ; s#/share#/#' | grep --color=none platform)/etc/eclipse.ini" | sed 's/.*=//')"
fi

echo $ECLIM_ECLIPSE_HOME
echo $ECLIPSE_VERSION
echo $PLUGINS_DIR


ant \
  -Declipse.local=$HOME/.eclipse/org.eclipse.platform_$ECLIPSE_VERSION \
  -Dplugins.dir=$PLUGINS_DIR \
  -Dvim.files=$XDG_CONFIG_HOME/nvim \
  || exit 1

if [ -f "/etc/NIXOS" ]
then
  dir=$(find $HOME/.eclipse/org.eclipse.platform_$ECLIPSE_VERSION/plugins/ -name nailgun -type d)
  dir="${dir%/*}/bin"
  
  mv -v $dir/ng $dir/ng2
  ln -vs $(which ng) $dir/ng
fi
