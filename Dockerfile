FROM ubuntu:15.10

MAINTAINER Fred Cox "mcfedr@gmail.com"

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y software-properties-common libncurses5:i386 libstdc++6:i386 zlib1g:i386 expect wget curl git build-essential \
    && add-apt-repository -y ppa:webupd8team/java \
    && curl -sL https://deb.nodesource.com/setup_5.x | bash - \
    && apt-get update \
    && echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
    && apt-get install -y oracle-java8-installer nodejs \
    && apt-get autoclean

ENV ANDROID_SDK_URL http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz

RUN cd /opt \
    && wget --output-document=android-sdk.tgz --quiet $ANDROID_SDK_URL \
    && tar xzf android-sdk.tgz && rm -f android-sdk.tgz \
    && chown -R root.root android-sdk-linux

ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

COPY tools /opt/tools
ENV PATH ${PATH}:/opt/tools

ENV ANDROID_PLATFORM_VERSION 23
ENV ANDROID_BUILD_TOOLS_VERSION 23.0.3
ENV ANDROID_EXTRA_PACKAGES android-22,build-tools-22.0.1,build-tools-23.0.0,build-tools-23.0.1,build-tools-23.0.2
ENV ANDROID_REPOSITORIES extra-android-m2repository,extra-android-support,extra-google-m2repository

RUN /opt/tools/android-accept-licenses.sh "android update sdk --no-ui --all --filter tools,platform-tools,build-tools-$ANDROID_BUILD_TOOLS_VERSION,android-$ANDROID_PLATFORM_VERSION,$ANDROID_EXTRA_PACKAGES,$ANDROID_REPOSITORIES"

RUN npm install -g xcode-build-tools@3.0.0

RUN mkdir -p /opt/workspace
WORKDIR /opt/workspace
