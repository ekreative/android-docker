# Android docker image

An image that lets us build android apps with docker using gitlab-ci

## Tags available

* `34`
* `34-emulator`
* `34-ndk`
* `34-stf-client`
* `34-jdk11`
* `33`
* `33-emulator`
* `33-ndk`
* `33-stf-client`
* `33-jdk17`
* `32`
* `32-emulator`
* `32-ndk`
* `32-stf-client`
* `32-jdk17`

## Unmaintained tags

* `31`
* `31-emulator`
* `31-ndk`
* `31-stf-client`
* `30`
* `30-emulator`
* `30-ndk`
* `30-stf-client`
* `30-ruby-bundler` (ruby included in all builds now)
* `31-ruby-bundler`
* `29`
* `29-emulator`
* `29-ndk`
* `29-stf-client`
* `29-ruby-bundler`
* `28`
* `28-emulator`
* `28-ndk`
* `28-stf-client`

## Build an app

```bash
docker run -ti --rm --volume=$(pwd):/srv -w /srv ekreative/android ./gradlew assemble
```

## Use emulator

```bash
docker run --rm -ti -v /dev/kvm:/dev/kvm --privileged ekreative/android
android-start-emulator
/gradlew cAT
```

## Contributing

This repo stores commited versions of Dockerfiles generated using the `./update.sh` script.
To update the Dockerfiles, run `./update.sh` and commit the changes.
When adding new versions remember to update the github workflow so that it builds them all.
I tend to remove an older version when adding a new one. To keep just the last 2-3 versions being built. Remove old
versions from the `Dockerfile`.
You should also update the list of tags in the README.md file.

## Credit

Borrowed a few ideas from [jacekmarchwicki/android](https://hub.docker.com/r/jacekmarchwicki/android/)
And license accepter from [thyrlian/AndroidSDK](https://github.com/thyrlian/AndroidSDK/blob/master/android-sdk/license_accepter.sh)

## Finding new packages

I use this command to list the available packages

```bash
sdkmanager --list
```
