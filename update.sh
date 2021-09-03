#!/usr/bin/env bash
set -e

variants=('29' '30' '31')

node_variants=('14')
default_node_variant='14'

jdk_variants=('11')
default_jdk_variant='11'

declare -A buildTools=(
  ['29']='29.0.3'
  ['30']='30.0.2'
  ['31']='31.0.0'
)

declare -A extraPackages=(
  ['29']='"build-tools;29.0.0 build-tools;29.0.1 build-tools;29.0.2"'
  ['30']='"build-tools;30.0.0 build-tools;30.0.1"'
  ['31']=''
)

for variant in "${variants[@]}"; do
  for node_variant in "${node_variants[@]}"; do
    for jdk_variant in "${jdk_variants[@]}"; do
      for type in 'default' 'emulator' 'ndk' 'stf-client'; do
        template="Dockerfile.template"
        if [ "$type" != "default" ]; then
          dir="$variant-$type"
          if [ "$node_variant" != "$default_node_variant" ]; then
            break 1
          fi
          if [ "$jdk_variant" != "$default_jdk_variant" ]; then
            break 1
          fi
        else
          dir="$variant"
          if [ "$node_variant" != "$default_node_variant" ] && [ "$jdk_variant" != "$default_jdk_variant" ]; then
            break 1
          fi
        fi

        if [ "$node_variant" != "$default_node_variant" ]; then
          dir="$dir-node$node_variant"
        fi

        if [ "$jdk_variant" != "$default_jdk_variant" ]; then
          dir="$dir-jdk$jdk_variant"
        fi

        echo "$dir"

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
          s/%%NODE_VARIANT%%/'"$node_variant"'/;
          s/%%BUILD_TOOLS%%/'"${buildTools[$variant]}"'/;
          s/%%EXTRA_PACKAGES%%/'"${extraPackages[$variant]}"'/;
          s/%%JDK_VERSION%%/'"$jdk_variant"'/;
        ' $template >"$dir/Dockerfile"
      done
    done
  done
done
