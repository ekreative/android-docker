FROM ubuntu:focal
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    expect \
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
    apt-transport-https \
    gnupg \
    lsb-release \
  # For nodejs we use nodesource, its nice and easy and gets us the correct version
  # Find latest link https://github.com/nodesource/distributions/blob/master/README.md#installation-instructions
  && curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
  && echo "deb https://deb.nodesource.com/node_18.x $(lsb_release -s -c) main" | tee /etc/apt/sources.list.d/nodesource.list \
  && echo "deb-src https://deb.nodesource.com/node_18.x $(lsb_release -s -c) main" | tee -a /etc/apt/sources.list.d/nodesource.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    nodejs \
  && rm -rf /var/lib/apt/lists/*

# hadolint ignore=DL3016
RUN npm -g install xcode-build-tools yarn
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
ENV ANDROID_PLATFORM_VERSION=32
ENV ANDROID_BUILD_TOOLS_VERSION=32.0.0
ENV PATH=$ANDROID_SDK_ROOT/build-tools/$ANDROID_BUILD_TOOLS_VERSION:$PATH
ENV ANDROID_EXTRA_PACKAGES="build-tools;32.0.0"
ENV ANDROID_REPOSITORIES="extras;android;m2repository extras;google;m2repository"
ENV ANDROID_CONSTRAINT_PACKAGES="extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2 extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1 extras;m2repository;com;android;support;constraint;constraint-layout;1.0.0"
RUN sdkmanager --verbose "platform-tools" "platforms;android-$ANDROID_PLATFORM_VERSION" "build-tools;$ANDROID_BUILD_TOOLS_VERSION" $ANDROID_EXTRA_PACKAGES $ANDROID_REPOSITORIES $ANDROID_CONSTRAINT_PACKAGES




##<ruby-bundler>##
# hadolint ignore=DL3008,SC1091
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends gnupg2 \
  && rm -rf /var/lib/apt/lists/* \
  && gpg2 --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
  && curl -sSL https://get.rvm.io | bash -s stable --ruby --without-gems="rvm rubygems-bundler" \
  && echo "source /etc/profile.d/rvm.sh" >> /etc/bash.bashrc \
  && source /usr/local/rvm/scripts/rvm \
  && gem install bundler -v '~> 1.0' --force --no-document --default
SHELL [ "/bin/bash", "-lc" ]
CMD [ "/bin/bash", "-lc" ]
##</ruby-bundler>##
