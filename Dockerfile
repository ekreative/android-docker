FROM ubuntu:xenial

MAINTAINER Fred Cox "mcfedr@gmail.com"

# Install Java and required libs and nodejs for the helper

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y software-properties-common libncurses5:i386 libstdc++6:i386 zlib1g:i386 unzip cmake expect wget curl git build-essential \
    && apt-get install --reinstall ca-certificates \
    && add-apt-repository -y ppa:webupd8team/java \
    && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && apt-get update \
    && echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
    && apt-get install -y oracle-java8-installer nodejs \
    && apt-get autoclean

# Install the SDK

ENV ANDROID_SDK_URL https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip

RUN cd /opt \
    && wget --output-document=android-sdk.zip --quiet $ANDROID_SDK_URL \
    && unzip android-sdk.zip -d android-sdk-linux \
    && rm -f android-sdk.zip \
    && chown -R root:root android-sdk-linux

ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${PATH}

COPY tools /opt/tools
ENV PATH ${PATH}:/opt/tools

# Install Android platform and things

ENV ANDROID_PLATFORM_VERSION 25
ENV ANDROID_BUILD_TOOLS_VERSION 25.0.3
ENV ANDROID_EXTRA_PACKAGES "build-tools;25.0.2" "build-tools;25.0.1" "build-tools;25.0.0"
ENV ANDROID_REPOSITORIES "extras;android;m2repository" "extras;google;m2repository"
ENV ANDROID_NDK "ndk-bundle"

RUN android-accept-licenses "sdkmanager --verbose \"platform-tools\" \"platforms;android-$ANDROID_PLATFORM_VERSION\" \"build-tools;$ANDROID_BUILD_TOOLS_VERSION\" $ANDROID_EXTRA_PACKAGES $ANDROID_REPOSITORIES $ANDROID_NDK"

ENV ANDROID_NDK_HOME ${ANDROID_HOME}/ndk-bundle

# Install upload-apk helper

RUN npm install -g xcode-build-tools
