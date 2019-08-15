#!/usr/bin/env bash
set -e

declare -A buildTools=(
  ['28']='28.0.3'
	['29']='29.0.2'
)

declare -A extraPackages=(
	['28']='"build-tools;28.0.0" "build-tools;28.0.1" "build-tools;28.0.2"'
	['29']='"build-tools;29.0.0" "build-tools;29.0.1"'
)

for variant in '28' '29'; do
  for type in 'default' 'emulator'; do
    template="Dockerfile.template"
    if [ "$type" != "default" ]; then
      dir="$variant-$type"
    else
      dir="$variant"
    fi
    if [ "$type" != "emulator" ]; then
      rmEmu='/^ENV (ANDROID_EMULATOR_PACKAGE|ANDROID_EMULATOR_DEPS)/d;'
    else
      rmEmu=''
    fi
    mkdir -p "$dir"
    sed -E '
      '"$rmEmu"'
      s/%%VARIANT%%/'"$variant"'/;
      s/%%BUILD_TOOLS%%/'"${buildTools[$variant]}"'/;
      s/%%EXTRA_PACKAGES%%/'"${extraPackages[$variant]}"'/;
' $template > "$dir/Dockerfile"
    cp -r tools/ "$dir/tools/"
  done
done
