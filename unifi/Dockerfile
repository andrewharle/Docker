# Example build command= docker build -t unifi_temp . --progress=plain --add-host=aptcacher.internal:172.24.48.164 | tee build.log
FROM --platform=linux/arm/v7 baseimage_temp

#https://specs.opencontainers.org/image-spec/annotations/
LABEL org.opencontainers.image.authors="Andrew Harle <46223597+andrewharle@users.noreply.github.com>"
LABEL org.opencontainers.image.title="Unifi controller image (without mongodb) andrewharle.github.io"
LABEL org.opencontainers.image.source=https://github.com/andrewharle/Docker

#TODO - hold back cron as we have supercronic!!

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"

ENV ADOPTIUM_REPO_KEY 3B04D753C9050D9A5D343F39843C48A565F8F04B
ENV UNIFI_REPO_KEY 4A228B2D358A5094178285BE06E85760C0A52C50
ENV ANDREWHARLE_GITHUB_KEY B6D32792566F0D55059947A90CDEA3BBE213DA29
ENV UNAME unifi

RUN set -eux; \
	groupadd --gid 999 --system $UNAME; \
	useradd --uid 999 --system --gid $UNAME $UNAME; \
    mkdir -p /app /config /defaults && \
	chown -R $UNAME:$UNAME /app /config /defaults

RUN set -ex; \
    mkdir -p /etc/apt/keyrings && \
    gpg -k && \
    gpg --no-default-keyring --keyring /etc/apt/keyrings/adoptium.gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys $ADOPTIUM_REPO_KEY && \
    gpg --no-default-keyring --keyring /etc/apt/keyrings/unifi.gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys $UNIFI_REPO_KEY && \
    gpg --no-default-keyring --keyring /etc/apt/keyrings/andrewharle_repo.gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys $ANDREWHARLE_GITHUB_KEY && \
    echo "deb [arch=armhf signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/100-adoptium.list && \
    echo 'deb [arch=armhf signed-by=/etc/apt/keyrings/unifi.gpg] https://www.ui.com/downloads/unifi/debian stable ubiquiti' | tee /etc/apt/sources.list.d/100-ubnt-unifi.list && \
    echo "deb [arch=armhf signed-by=/etc/apt/keyrings/andrewharle_repo.gpg] https://andrewharle.github.io/REPO/debian dummy misc" | tee /etc/apt/sources.list.d/100-andrewharle_repo.list

RUN set -ex; \
    echo "**** install packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        binutils \
        jsvc \
        libcap2 \
        logrotate \
        temurin-8-jdk \
        unifi \
        mongodb-server && \
    echo "**** cleanup ****" && \
    apt-get clean && \
    rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/*

# add local files
RUN set -ex; \
    echo "**** Copying Local Files****"
COPY root/ /
RUN chmod +x /sbin/unifi_init/*.sh

# Volumes and Ports
WORKDIR /usr/lib/unifi
#VOLUME /config
EXPOSE 8080 8443 8843 8880

ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=180000

ENTRYPOINT ["/init"]