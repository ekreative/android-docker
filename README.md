# Android docker image

An image that lets us build android apps with docker using gitlab-ci

## Build command

    docker build -t ekreative/android .

## Build an app

    docker run -ti --rm --volume=$(pwd):/srv -w /srv ekreative/android ./gradlew assembleRelease

## Credit

Borrowed a few ideas from [jacekmarchwicki/android](https://hub.docker.com/r/jacekmarchwicki/android/)

## Finding new packages

I use this command to list the available packages

    sdkmanager --list
