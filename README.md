# Android docker image

An image that lets us build android apps with docker.

## Build command

    docker build -t mcfedr/android .

## Build an app

    docker run -ti --rm --volume=$(pwd):/opt/workspace mcfedr/android ./gradlew assembleRelease

## Credit

Borrowed a few ideas from [jacekmarchwicki/android](https://hub.docker.com/r/jacekmarchwicki/android/)
