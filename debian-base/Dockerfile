#TODO: Setup haveged service

#IMPORTANT use "--add-host" directive in linux in combination with an Apt-Cacher NG server.
# On linux e.g. docker build -t debian_buildenv . --add-host=aptcacher.internal:host-gateway
# On WSL e.g. docker build -t debian_buildenv . --add-host=aptcacher.internal:host.docker.internal (or whichever host for the aptcache)

FROM --platform=$TARGETPLATFORM debian:bullseye-slim

#https://specs.opencontainers.org/image-spec/annotations/
LABEL org.opencontainers.image.authors="Andrew Harle <46223597+andrewharle@users.noreply.github.com>"
LABEL org.opencontainers.image.title="Base image andrewharle.github.io"
LABEL org.opencontainers.image.source=https://github.com/andrewharle/Docker

# set environment variables
ARG DEBIAN_FRONTEND="noninteractive"
ENV ANDREWHARLE_GITHUB_KEY B6D32792566F0D55059947A90CDEA3BBE213DA29

# make the "en_GB.UTF-8" locale so builds will be utf-8 enabled by default
RUN set -eux; \
    echo "**** install apt-utils and locales ****" && \
        echo 'Acquire::http { Proxy "http://aptcacher.internal:3142"; };' >> /etc/apt/apt.conf.d/01proxy && \
        apt-get update && \
        apt-get upgrade -y && \
        apt-get install -y \
        apt-utils && \
    echo "**** install packages ****" && \
        apt-get install -y \
        curl \
        wget \
        patch \
        tzdata \ 
        haveged \
        ca-certificates \
        apt-transport-https \
        xz-utils \
        gpg \
        gosu && \
    echo "**** generate locale ****" && \
        if [ -f /etc/dpkg/dpkg.cfg.d/docker ]; then \
        # if this file exists, we're likely in "debian:xxx-slim", and locales are thus being excluded so we need to remove that exclusion (since we need locales)
            grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
            sed -ri '/\/usr\/share\/locale/d' /etc/dpkg/dpkg.cfg.d/docker; \
            ! grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
        fi; \
        apt-get install -y --no-install-recommends locales; \
        localedef -i en_GB -c -f UTF-8 -A /usr/share/locale/locale.alias en_GB.UTF-8; \
        #locale-gen en_GB.UTF-8 && \
    echo "**** cleanup ****" && \
        apt-get remove -y patch &&\
        apt-get autoremove && \
        apt-get clean && \
        rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/*

ENV LANG=en_GB.utf8

#Add the s6-overlay and supercronic
RUN set -eux; \
    gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys $ANDREWHARLE_GITHUB_KEY; \
    echo "**** install s6-overlay ****" && \
    wget -q -P /tmp https://andrewharle.github.io/Software/Builds/s6-overlay/s6-overlay.releases; \
    wget -qO- https://andrewharle.github.io/Software/Builds/s6-overlay/s6-overlay.releases.asc | gpg --verify - /tmp/s6-overlay.releases ; \
    # Print s6-overlay architecture - See https://wiki.debian.org/ArchitectureSpecificsMemo
    arch | sed s/armv7l/armhf/ > /opt/architecture-gnu-cpu; \
    cat /tmp/s6-overlay.releases | grep "s6-overlay-noarch" >> /tmp/s6-overlay.releases.dl; \
    cat /tmp/s6-overlay.releases | grep "s6-overlay-"$(cat /opt/architecture-gnu-cpu) >> /tmp/s6-overlay.releases.dl; \
    cat /tmp/s6-overlay.releases | grep "s6-overlay-symlinks-noarch" >> /tmp/s6-overlay.releases.dl; \
    cat /tmp/s6-overlay.releases | grep "s6-overlay-symlinks-arch" >> /tmp/s6-overlay.releases.dl; \
    cat /tmp/s6-overlay.releases | grep "syslogd-overlay-noarch" >> /tmp/s6-overlay.releases.dl; \
    cat /tmp/s6-overlay.releases | grep ".sha*" >> /tmp/s6-overlay.releases.dl; \
    wget -q -i /tmp/s6-overlay.releases.dl -P /tmp/s6-overlay/; \
    cd /tmp/s6-overlay && gpg --verify *.asc && sha256sum -c --ignore-missing *.sha256sum; \
    ls *.xz | xargs -I{} tar -C / -Jxpf {}; \
    cd / && rm -rf /tmp/*; \
    echo "**** install supercronic ****" && \
    wget -q -P /tmp https://andrewharle.github.io/Software/Builds/supercronic/supercronic.releases; \
    wget -qO- https://andrewharle.github.io/Software/Builds/supercronic/supercronic.releases.asc | gpg --verify - /tmp/supercronic.releases ; \
    # Print supercronic architecture - See https://wiki.debian.org/ArchitectureSpecificsMemo
    arch | sed "/x86_64/c amd64" | sed "/i*86/c 386" | sed "/arm/c arm" | sed "/aarch64/c arm64" > /opt/architecture-supercronic-cpu; \
    cat /tmp/supercronic.releases | grep "supercronic-linux-"$(cat /opt/architecture-supercronic-cpu)"\$" >> /tmp/supercronic.releases.dl; \
    cat /tmp/supercronic.releases | grep ".sha*" >> /tmp/supercronic.releases.dl; \
    wget -q -i /tmp/supercronic.releases.dl -P /tmp/supercronic/; \
    cd /tmp/supercronic && gpg --verify *.asc && sha256sum -c --ignore-missing *.sha256sum; \
    mkdir -p /opt/supercronic/bin/ && cp "supercronic-linux-"$(cat /opt/architecture-supercronic-cpu) /opt/supercronic/bin/supercronic; \
    cd / && rm -rf /tmp/*;

    