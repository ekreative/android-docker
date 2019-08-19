FROM ubuntu:disco

MAINTAINER Fred Cox "mcfedr@gmail.com"

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    expect \
    locales \
    nano \
    # Sticking to jdk8 for the moment
    # Problems with Kapt on JDK>8, https://youtrack.jetbrains.com/issue/KT-28587
    # Also 8 is whats included with Android Studio
    openjdk-8-jdk \
    unzip \
    wget \
  && rm -rf /var/lib/apt/lists/*

# Seems somethings build better with utf8 locale specified
# http://jaredmarkell.com/docker-and-locales/
# https://github.com/square/moshi/issues/804#issuecomment-466926878
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install the SDK
ENV ANDROID_SDK_URL https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN cd /opt \
  && wget --output-document=android-sdk.zip --quiet $ANDROID_SDK_URL \
  && unzip android-sdk.zip -d android-sdk-linux \
  && rm -f android-sdk.zip \
  && chown -R root:root android-sdk-linux

ENV ANDROID_SDK_ROOT /opt/android-sdk-linux
ENV ANDROID_HOME $ANDROID_SDK_ROOT
ENV PATH $ANDROID_SDK_ROOT/tools/bin:$ANDROID_SDK_ROOT/tools:$ANDROID_SDK_ROOT/platform-tools:$PATH

# Libs required for sdkmanager to run using openjdk-12
# https://stackoverflow.com/a/55982976/859027
# Removed as currently back on jdk 8
#RUN mkdir /opt/jaxb_lib \
#  && wget http://central.maven.org/maven2/javax/activation/activation/1.1.1/activation-1.1.1.jar -O /opt/jaxb_lib/activation.jar \
#  && wget http://central.maven.org/maven2/javax/xml/jaxb-impl/2.1/jaxb-impl-2.1.jar -O /opt/jaxb_lib/jaxb-impl.jar \
#  && wget http://central.maven.org/maven2/org/glassfish/jaxb/jaxb-xjc/2.3.2/jaxb-xjc-2.3.2.jar -O /opt/jaxb_lib/jaxb-xjc.jar \
#  && wget http://central.maven.org/maven2/org/glassfish/jaxb/jaxb-core/2.3.0.1/jaxb-core-2.3.0.1.jar -O /opt/jaxb_lib/jaxb-core.jar \
#  && wget http://central.maven.org/maven2/org/glassfish/jaxb/jaxb-jxc/2.3.2/jaxb-jxc-2.3.2.jar -O /opt/jaxb_lib/jaxb-jxc.jar \
#  && wget http://central.maven.org/maven2/javax/xml/bind/jaxb-api/2.3.1/jaxb-api-2.3.1.jar -O /opt/jaxb_lib/jaxb-api.jar \
#  && sed -i '/^CLASSPATH=/a CLASSPATH=/opt/jaxb_lib/activation.jar:/opt/jaxb_lib/jaxb-impl.jar:/opt/jaxb_lib/jaxb-xjc.jar:/opt/jaxb_lib/jaxb-core.jar:/opt/jaxb_lib/jaxb-jxc.jar:/opt/jaxb_lib/jaxb-api.jar:$CLASSPATH' $ANDROID_SDK_ROOT/tools/bin/sdkmanager \
#  && sed -i '/^CLASSPATH=/a CLASSPATH=/opt/jaxb_lib/activation.jar:/opt/jaxb_lib/jaxb-impl.jar:/opt/jaxb_lib/jaxb-xjc.jar:/opt/jaxb_lib/jaxb-core.jar:/opt/jaxb_lib/jaxb-jxc.jar:/opt/jaxb_lib/jaxb-api.jar:$CLASSPATH' $ANDROID_SDK_ROOT/tools/bin/avdmanager

# Install custom tools
COPY tools/license_accepter /opt/tools/
ENV PATH /opt/tools:$PATH
RUN license_accepter

# Install Android platform and things
ENV ANDROID_PLATFORM_VERSION 28
ENV ANDROID_BUILD_TOOLS_VERSION 28.0.3
ENV PATH $ANDROID_SDK_ROOT/build-tools/$ANDROID_BUILD_TOOLS_VERSION:$PATH
ENV ANDROID_EXTRA_PACKAGES "build-tools;28.0.0" "build-tools;28.0.1" "build-tools;28.0.2"
ENV ANDROID_REPOSITORIES "extras;android;m2repository" "extras;google;m2repository"
ENV ANDROID_CONSTRAINT_PACKAGES "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1" "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.0"
RUN sdkmanager --verbose "platform-tools" "platforms;android-$ANDROID_PLATFORM_VERSION" "build-tools;$ANDROID_BUILD_TOOLS_VERSION" $ANDROID_EXTRA_PACKAGES $ANDROID_REPOSITORIES $ANDROID_CONSTRAINT_PACKAGES

##<stf-client>##
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ruby \
  && savedAptMark="$(apt-mark showmanual)" \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    # stf-client
    build-essential \
    # gem specific_install
    git \
  # Without rake fails to install stf-client
  && gem install specific_install rake \
  # && gem install rake stf-client \
  # https://github.com/Malinskiy/stf-client/pull/10
  && gem specific_install https://github.com/mcfedr/stf-client.git add-adb-key \
  && apt-mark auto '.*' > /dev/null \
  && apt-mark manual $savedAptMark > /dev/null \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/*
##</stf-client>##


