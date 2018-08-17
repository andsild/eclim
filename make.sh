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
  export ECLIM_ECLIPSE_HOME="$(getExec() { while read -r line ; do awk '/exec/ { gsub(/"/, ""); print $2 }' <<<$line ; done ; }; dirname "$(cat $(cat $(readlink $(command -v eclipse)) | getExec ) | getExec))" )"

  ECLIPSE_VERSION="$(awk -F = '/version/ { print $2 }' "$ECLIM_ECLIPSE_HOME/.eclipseproduct")"
  PLUGINS_DIR="$(sed -n '/dropins\.directory/ s/.*=//p' $(dirname $(readlink $(command -v eclipse)))/../etc/eclipse.ini)"
  ECLIPSE_HOME_DIR="$HOME/.eclipse/org.eclipse.platform_$ECLIPSE_VERSION"
  rm -rv "${ECLIPSE_HOME_DIR}"/dropins
  ln -s "$PLUGINS_DIR" "${ECLIPSE_HOME_DIR}"/

fi

echo "$ECLIM_ECLIPSE_HOME"
echo "$ECLIPSE_VERSION"
echo "$PLUGINS_DIR"

ant \
  -Declipse.local="$HOME/.eclipse/org.eclipse.platform_$ECLIPSE_VERSION" \
  -Dplugins.dir="$PLUGINS_DIR" \
  -Dvim.files="$XDG_CONFIG_HOME/nvim" \
  || exit 1

if [ -f "/etc/NIXOS" ]
then
  dir="$(find "$HOME/.eclipse/org.eclipse.platform_$ECLIPSE_VERSION/plugins/" -name nailgun -type d)"
  dir="${dir%/*}/bin"
  
  mv -v "$dir/ng" "$dir/ng2"
  ln -vs "$(command -v ng)" "$dir/ng"
fi
