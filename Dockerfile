FROM mcr.microsoft.com/dotnet/core/sdk:3.1.403

# Dockerfile Information
LABEL maintainer="sijaymm" \
    app_name="sonar-msbuild"

ENV SONAR_SCANNER_MSBUILD_VERSION=4.10.0.19059 \
    DOTNETCORE_SDK=3.1.403 \
    DOTNETCORE_RUNTIME=3.1.9 \
    NETCOREAPP_VERSION=netcoreapp3.0 \
    DOCKER_VERSION=5:19.03.12~3-0~debian-buster \
    CONTAINERD_VERSION=1.2.13-2 \
    OPENJDK_VERSION=11

# Linux update / latest pull
RUN apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common

# Install Java dependencies
RUN apt-get install -y openjdk-$OPENJDK_VERSION-jre

# Install all necessary additional software
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
    && apt-key fingerprint 0EBFCD88 \
    && add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/debian \
        $(lsb_release -cs) \
        stable" \
    && apt-get update \
    && apt-get install -y \
        docker-ce=$DOCKER_VERSION \
        docker-ce-cli=$DOCKER_VERSION \
        containerd.io=$CONTAINERD_VERSION

# Install Sonar Scanner
RUN apt-get install -y unzip \
    && wget https://github.com/SonarSource/sonar-scanner-msbuild/releases/download/$SONAR_SCANNER_MSBUILD_VERSION/sonar-scanner-msbuild-$SONAR_SCANNER_MSBUILD_VERSION-$NETCOREAPP_VERSION.zip \
    && unzip sonar-scanner-msbuild-$SONAR_SCANNER_MSBUILD_VERSION-$NETCOREAPP_VERSION.zip -d /sonar-scanner \
    && rm sonar-scanner-msbuild-$SONAR_SCANNER_MSBUILD_VERSION-$NETCOREAPP_VERSION.zip \
    && chmod +x -R /sonar-scanner

# Cleanup cached files
RUN apt-get -q autoremove \
    && apt-get -q clean -y \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*.bin
