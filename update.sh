#!/usr/bin/env bash
set -e

variants=('30' '31' '32' '33')

## Disabled creating extra node variants, rather just having a default for each SDK
#node_variants=('14' '18')
declare -A default_node_variants=(
  ['30']='14'
  ['31']='14'
  ['32']='18'
  ['33']='18'
)

jdk_variants=('11')
default_jdk_variant='11'

declare -A build_tools=(
  ['30']='30.0.3'
  ['31']='31.0.0'
  ['32']='32.0.0'
  ['33']='33.0.0'
)

declare -A extra_packages=(
  ['30']='"build-tools;30.0.0 build-tools;30.0.1 build-tools;30.0.2"'
  ['31']='"build-tools;31.0.0"'
  ['32']='"build-tools;32.0.0"'
  ['33']='"build-tools;33.0.0 build-tools;33.0.1 build-tools;33.0.2"'
)

for variant in "${variants[@]}"; do
  #  for node_variant in "${node_variants[@]}"; do
  for jdk_variant in "${jdk_variants[@]}"; do
    for type in 'default' 'emulator' 'ndk' 'stf-client'; do
      template="Dockerfile.template"
      default_node_variant="${default_node_variants[$variant]}"
      node_variant="$default_node_variant"
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

      extra_sed=''
      if [ "$type" = "emulator" ]; then
        cp -r tools-emulator/ "$dir/tools-emulator/"
      else
        extra_sed='
            '"$extra_sed"'
            /##<emulator>##/,/##<\/emulator>##/d;
          '
      fi
      if [ "$type" != "ndk" ]; then
        extra_sed='
            '"$extra_sed"'
            /##<ndk>##/,/##<\/ndk>##/d;
          '
      fi
      if [ "$type" != "stf-client" ]; then
        extra_sed='
            '"$extra_sed"'
            /##<stf-client>##/,/##<\/stf-client>##/d;
          '
      fi
      sed -E '
          '"$extra_sed"'
          s/%%VARIANT%%/'"$variant"'/;
          s/%%NODE_VARIANT%%/'"$node_variant"'/;
          s/%%BUILD_TOOLS%%/'"${build_tools[$variant]}"'/;
          s/%%EXTRA_PACKAGES%%/'"${extra_packages[$variant]}"'/;
          s/%%JDK_VERSION%%/'"$jdk_variant"'/;
        ' $template >"$dir/Dockerfile"
    done
  done
  #  done
done
