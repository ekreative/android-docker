FROM ubuntu:jammy
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  expect \
  apt-utils \
  locales \
  nano \
  openjdk-17-jdk \
  unzip \
  curl \
  xz-utils \
  git \
  && rm -rf /var/lib/apt/lists/*

# Seems somethings build better with utf8 locale specified
# http://jaredmarkell.com/docker-and-locales/
# https://github.com/square/moshi/issues/804#issuecomment-466926878
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

##<node>##
# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  ca-certificates \
  apt-transport-https \
  gnupg \
  lsb-release \
  # For nodejs we use nodesource, its nice and easy and gets us the correct version
  # Find latest link https://github.com/nodesource/distributions/blob/master/README.md#installation-instructions
  && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --dearmor -o /usr/share/keyrings/nodesource.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/nodesource.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
  nodejs \
  && rm -rf /var/lib/apt/lists/*

# hadolint ignore=DL3016
RUN npm install -g xcode-build-tools yarn
##</node>##

# Install the SDK
# https://developer.android.com/studio#downloads
ENV ANDROID_CMDLINE_TOOLS=https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
# hadolint ignore=DL3003
RUN ( \
  cd /opt \
  && mkdir android-sdk-linux \
  && curl -sSL -o cmdline-tools.zip "$ANDROID_CMDLINE_TOOLS" \
  && unzip cmdline-tools.zip -d android-sdk-linux/cmdline-tools \
  && rm -f cmdline-tools.zip \
  && chown -R root:root android-sdk-linux \
  )

ENV ANDROID_SDK_ROOT=/opt/android-sdk-linux
ENV ANDROID_HOME=$ANDROID_SDK_ROOT
ENV PATH=$ANDROID_HOME/cmdline-tools/cmdline-tools/bin:$ANDROID_HOME/cmdline-tools/tools/bin:$ANDROID_SDK_ROOT/tools/bin:$ANDROID_SDK_ROOT/tools:$ANDROID_SDK_ROOT/platform-tools:$PATH

# Install custom tools
COPY tools/license_accepter /opt/tools/
COPY tools/adb-all /opt/tools
ENV PATH=/opt/tools:$PATH
RUN license_accepter

# Install Android platform and things
ENV ANDROID_PLATFORM_VERSION=34
ENV ANDROID_BUILD_TOOLS_VERSION=34.0.0
ENV PATH=$ANDROID_SDK_ROOT/build-tools/$ANDROID_BUILD_TOOLS_VERSION:$PATH
ENV ANDROID_EXTRA_PACKAGES=
ENV ANDROID_REPOSITORIES="extras;android;m2repository extras;google;m2repository"
#ENV ANDROID_CONSTRAINT_PACKAGES="extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2 extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1 extras;m2repository;com;android;support;constraint;constraint-layout;1.0.0"
RUN sdkmanager --update && \
    sdkmanager --verbose \
      "platform-tools" \
      "platforms;android-${ANDROID_PLATFORM_VERSION}" \
      "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
      ${ANDROID_EXTRA_PACKAGES:+${ANDROID_EXTRA_PACKAGES}} \
      ${ANDROID_REPOSITORIES:+${ANDROID_REPOSITORIES}} \
      ${ANDROID_CONSTRAINT_PACKAGES:+${ANDROID_CONSTRAINT_PACKAGES}}


##<emulator>##
# hadolint ignore=DL3008
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  file \
  qtbase5-dev \
  libpulse0 \
  && rm -rf /var/lib/apt/lists/*

ENV ANDROID_EMULATOR_PACKAGE="system-images;android-$ANDROID_PLATFORM_VERSION;google_apis_playstore;x86_64"
RUN sdkmanager --verbose "emulator" $ANDROID_EMULATOR_PACKAGE

# Fix for emulator detect 64bit
ENV SHELL=/bin/bash 
# https://www.bram.us/2017/05/12/launching-the-android-emulator-from-the-command-line/
ENV PATH=$ANDROID_SDK_ROOT/emulator:$PATH

COPY tools-emulator/android-start-emulator /opt/tools/
COPY tools-emulator/android-wait-for-emulator /opt/tools/
RUN adb keygen ~/.android/adbkey
##</emulator>##


##<ruby-bundler>##
# hadolint ignore=DL3008,SC1091
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends gnupg2 build-essential \
  && rm -rf /var/lib/apt/lists/* \
  && gpg2 --keyserver keyserver.ubuntu.com --recv-keys \
  409B6B1796C275462A1703113804BB82D39DC0E3 \
  7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
  && curl -sSL https://get.rvm.io | bash -s stable --without-gems="rvm rubygems-bundler" \
  && echo 'source /usr/local/rvm/scripts/rvm' >> /etc/bash.bashrc

ENV BASH_ENV="/usr/local/rvm/scripts/rvm"

RUN bash -c "source /usr/local/rvm/scripts/rvm && \
  rvm install 3.1.2 && \
  rvm install 3.4.3 && \
  rvm alias create default 3.4.3 && \
  rvm use 3.1.2 && \
  gem install bundler -v '~>2.0' --no-document && \
  rvm use 3.4.3 && \
  gem install bundler -v '~>2.0' --no-document"
##</ruby-bundler>##
