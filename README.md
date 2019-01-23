# Android docker image

An image that lets us build android apps with docker using gitlab-ci

## Build command

```bash
docker build -t ekreative/android .
```

## Build an app

```bash
docker run -ti --rm --volume=$(pwd):/srv -w /srv ekreative/android ./gradlew assembleRelease
```

## Credit

Borrowed a few ideas from [jacekmarchwicki/android](https://hub.docker.com/r/jacekmarchwicki/android/)
And license accepter from [thyrlian/AndroidSDK](https://github.com/thyrlian/AndroidSDK/blob/master/android-sdk/license_accepter.sh)

## Finding new packages

I use this command to list the available packages

```bash
sdkmanager --list
```
