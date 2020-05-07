#!/usr/bin/env bash
set -e

declare -A buildTools=(
  ['28']='28.0.3'
	['29']='29.0.3'
)

declare -A extraPackages=(
	['28']='"build-tools;28.0.0" "build-tools;28.0.1" "build-tools;28.0.2"'
	['29']='"build-tools;29.0.0" "build-tools;29.0.1" "build-tools;29.0.2"'
)

for variant in '28' '29'; do
  for type in 'default' 'emulator' 'ndk' 'stf-client'; do
    template="Dockerfile.template"
    if [ "$type" != "default" ]; then
      dir="$variant-$type"
    else
      dir="$variant"
    fi
    rm -rf "$dir"
    mkdir -p "$dir"
    cp -r tools/ "$dir/tools/"

    extraSed=''
    if [ "$type" = "emulator" ]; then
      cp -r tools-emulator/ "$dir/tools-emulator/"
    else
      extraSed='
        '"$extraSed"'
        /##<emulator>##/,/##<\/emulator>##/d;
      '
    fi
    if [ "$type" != "ndk" ]; then
      extraSed='
        '"$extraSed"'
        /##<ndk>##/,/##<\/ndk>##/d;
      '
    fi
    if [ "$type" != "stf-client" ]; then
      extraSed='
        '"$extraSed"'
        /##<stf-client>##/,/##<\/stf-client>##/d;
      '
    fi
    sed -E '
      '"$extraSed"'
      s/%%VARIANT%%/'"$variant"'/;
      s/%%BUILD_TOOLS%%/'"${buildTools[$variant]}"'/;
      s/%%EXTRA_PACKAGES%%/'"${extraPackages[$variant]}"'/;
    ' $template > "$dir/Dockerfile"
  done
done
