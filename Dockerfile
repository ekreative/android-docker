FROM ubuntu:disco

MAINTAINER Fred Cox "mcfedr@gmail.com"

ENV ANDROID_EMULATOR_DEPS "file qt5-default libpulse0"

RUN apt-get update \
    && apt-get install -y \
       apt-transport-https \
       curl \
       gnupg \
       lsb-release \
       wget \
# For nodejs we use nodesource, its nice and easy and gets us the correct version
# Find latest link https://github.com/nodesource/distributions/blob/master/README.md#installation-instructions
    && curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
    && echo "deb https://deb.nodesource.com/node_12.x $(lsb_release -s -c) main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      # stf-client
      build-essential \
      expect \
      # emulator
      file \
      # emulator
      libpulse0 \
      nano \
      nodejs \
      openjdk-12-jdk \
      # gcloud
      python2 \
      # stf-client
      ruby \
      # emulator
      qt5-default \
    && rm -rf /var/lib/apt/lists/*

# Find latest link at https://cloud.google.com/sdk/docs/downloads-versioned-archives
ENV GCLOUD_SDK_VERSION 258.0.0
ENV PATH=/google-cloud-sdk/bin:$PATH
RUN curl https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-$GCLOUD_SDK_VERSION-linux-x86_64.tar.gz | tar -xzf - \
    && /google-cloud-sdk/install.sh \
    && gcloud components install gsutil beta

# Install the SDK
ENV ANDROID_SDK_URL https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN cd /opt \
    && wget --output-document=android-sdk.zip --quiet $ANDROID_SDK_URL \
    && unzip android-sdk.zip -d android-sdk-linux \
    && rm -f android-sdk.zip \
    && chown -R root:root android-sdk-linux

ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${PATH}

# Libs required for sdkmanager to run using openjdk-12
RUN mkdir /opt/jaxb_lib \
  && wget http://central.maven.org/maven2/javax/activation/activation/1.1.1/activation-1.1.1.jar -O /opt/jaxb_lib/activation.jar \
  && wget http://central.maven.org/maven2/javax/xml/jaxb-impl/2.1/jaxb-impl-2.1.jar -O /opt/jaxb_lib/jaxb-impl.jar \
  && wget http://central.maven.org/maven2/org/glassfish/jaxb/jaxb-xjc/2.3.2/jaxb-xjc-2.3.2.jar -O /opt/jaxb_lib/jaxb-xjc.jar \
  && wget http://central.maven.org/maven2/org/glassfish/jaxb/jaxb-core/2.3.0.1/jaxb-core-2.3.0.1.jar -O /opt/jaxb_lib/jaxb-core.jar \
  && wget http://central.maven.org/maven2/org/glassfish/jaxb/jaxb-jxc/2.3.2/jaxb-jxc-2.3.2.jar -O /opt/jaxb_lib/jaxb-jxc.jar \
  && wget http://central.maven.org/maven2/javax/xml/bind/jaxb-api/2.3.1/jaxb-api-2.3.1.jar -O /opt/jaxb_lib/jaxb-api.jar \
  && sed -i '/^CLASSPATH=/a CLASSPATH=/opt/jaxb_lib/activation.jar:/opt/jaxb_lib/jaxb-impl.jar:/opt/jaxb_lib/jaxb-xjc.jar:/opt/jaxb_lib/jaxb-core.jar:/opt/jaxb_lib/jaxb-jxc.jar:/opt/jaxb_lib/jaxb-api.jar:$CLASSPATH' $ANDROID_HOME/tools/bin/sdkmanager \
  && sed -i '/^CLASSPATH=/a CLASSPATH=/opt/jaxb_lib/activation.jar:/opt/jaxb_lib/jaxb-impl.jar:/opt/jaxb_lib/jaxb-xjc.jar:/opt/jaxb_lib/jaxb-core.jar:/opt/jaxb_lib/jaxb-jxc.jar:/opt/jaxb_lib/jaxb-api.jar:$CLASSPATH' $ANDROID_HOME/tools/bin/avdmanager

# Install custom tools
COPY tools /opt/tools
ENV PATH /opt/tools:${PATH}
RUN license_accepter

# Install Android platform and things
ENV ANDROID_PLATFORM_VERSION 28
ENV ANDROID_BUILD_TOOLS_VERSION 28.0.3
ENV ANDROID_EXTRA_PACKAGES "build-tools;28.0.0" "build-tools;28.0.1" "build-tools;28.0.2"
ENV ANDROID_REPOSITORIES "extras;android;m2repository" "extras;google;m2repository"
ENV ANDROID_CONSTRAINT_PACKAGES "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1" "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.0"
ENV ANDROID_EMULATOR_PACKAGE "system-images;android-$ANDROID_PLATFORM_VERSION;google_apis_playstore;x86_64"
RUN android-accept-licenses "sdkmanager --verbose \"platform-tools\" \"emulator\" \"platforms;android-$ANDROID_PLATFORM_VERSION\" \"build-tools;$ANDROID_BUILD_TOOLS_VERSION\" $ANDROID_EXTRA_PACKAGES $ANDROID_REPOSITORIES $ANDROID_CONSTRAINT_PACKAGES $ANDROID_EMULATOR_PACKAGE"
ENV PATH ${ANDROID_HOME}/build-tools/${ANDROID_BUILD_TOOLS_VERSION}:${PATH}

# Fix for emulator detect 64bit
ENV SHELL /bin/bash
# https://www.bram.us/2017/05/12/launching-the-android-emulator-from-the-command-line/
ENV PATH $ANDROID_HOME/emulator:$PATH

# Install upload-apk helper
RUN npm install -g xcode-build-tools
# Without rake fails to install stf-client
RUN gem install rake stf-client
