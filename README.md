# Android docker image

An image that lets us build android apps with docker using gitlab-ci

## Tags available

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

## Build command

```bash
./update.sh
docker build -t ekreative/android:latest 30
```

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

## Credit

Borrowed a few ideas from [jacekmarchwicki/android](https://hub.docker.com/r/jacekmarchwicki/android/)
And license accepter from [thyrlian/AndroidSDK](https://github.com/thyrlian/AndroidSDK/blob/master/android-sdk/license_accepter.sh)

## Finding new packages

I use this command to list the available packages

```bash
sdkmanager --list
```
