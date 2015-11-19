FROM ubuntu:15.10

MAINTAINER Fred Cox "mcfedr@gmail.com"

RUN dpkg --add-architecture i386
RUN  apt-get update && apt-get install -y openjdk-7-jdk libncurses5:i386 libstdc++6:i386 zlib1g:i386 expect wget

RUN cd /opt && wget --output-document=android-sdk.tgz --quiet http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz && tar xzf android-sdk.tgz && rm -f android-sdk.tgz && chown -R root.root android-sdk-linux

ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

COPY tools /opt/tools
ENV PATH ${PATH}:/opt/tools

# --all --filter tool,platform,build-tools-23.0.0,android-23,extra-android-support,extra-android-m2repository,extra-google-m2repository,extra-google-google_play_services
RUN ["/opt/tools/android-accept-licenses.sh", "android update sdk --no-ui --all --filter tools,platform-tools,build-tools-23.0.0,build-tools-22.0.0,android-23,android-22,extra-android-m2repository,extra-android-support,extra-google-m2repository"]

RUN mkdir -p /opt/workspace
WORKDIR /opt/workspace
