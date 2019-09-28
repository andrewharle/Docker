FROM andrewharle/armhf-debian-qemu:buster

LABEL maintainer="Andrew Harle <46223597+andrewharle@users.noreply.github.com>"

RUN [ "cross-build-start" ]

ARG DEBIAN_FRONTEND=noninteractive

ENV BASEDIR=/usr/lib/unifi \
    DATADIR=/unifi/data \
    LOGDIR=/unifi/log \
    CERTDIR=/unifi/cert \
    RUNDIR=/var/run/unifi \
    ODATADIR=/var/lib/unifi \
    OLOGDIR=/var/log/unifi \
    CERTNAME=cert.pem \
    CERT_PRIVATE_NAME=privkey.pem \
    CERT_IS_CHAIN=false \
    GOSU_VERSION=1.10 \
    BIND_PRIV=true \
    RUNAS_UID0=true \
    UNIFI_GID=999 \
    UNIFI_UID=999

RUN set -eux; \
	apt-get update && apt-get upgrade -y; \
	apt-get install -y --no-install-recommends \
		apt-transport-https \
		ca-certificates \
        curl \
	; \
	if ! command -v ps > /dev/null; then \
		apt-get install -y --no-install-recommends procps; \
	fi; \
	rm -rf /var/lib/apt/lists/*

# grab gosu for easy step-down from root (https://github.com/tianon/gosu/releases)
ENV GOSU_VERSION 1.11

RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
        wget \
	; \
	if ! command -v gpg > /dev/null; then \
		apt-get install -y --no-install-recommends gnupg dirmngr; \
	fi; \
	rm -rf /var/lib/apt/lists/*; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	command -v gpgconf && gpgconf --kill all || :; \
	rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	chmod +x /usr/local/bin/gosu; \
	gosu nobody true; \
	\

# TODO some sort of download verification here
	\
	apt-get purge -y --auto-remove wget

#Install dummy mongodb package
ENV GPG_KEY B6D32792566F0D55059947A90CDEA3BBE213DA29
RUN set -ex; \
    \
    apt-key adv --keyserver hkps://keyserver.ubuntu.com --recv $GPG_KEY \
    ; \
    echo "deb https://andrewharle.github.io/REPO/debian dummy misc" | tee -a /etc/apt/sources.list \
    ; \
    apt-get update \
	&& apt-get install mongodb-server

RUN mkdir -p /usr/unifi \
     /usr/local/unifi/init.d \
     /usr/unifi/init.d
COPY docker-entrypoint.sh /usr/local/bin/
COPY docker-healthcheck.sh /usr/local/bin/
COPY docker-build.sh /usr/local/bin/
COPY functions /usr/unifi/functions
COPY import_cert /usr/unifi/init.d/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
 && chmod +x /usr/unifi/init.d/import_cert \
 && chmod +x /usr/local/bin/docker-healthcheck.sh \
 && chmod +x /usr/local/bin/docker-build.sh

 # Push installing openjdk-8-jre first, so that the unifi package doesn't pull in openjdk-7-jre as a dependency? Else uncomment and just go with openjdk-7.
RUN set -ex \
 && mkdir -p /usr/share/man/man1/ \
 && groupadd -r unifi -g $UNIFI_GID \
 && useradd --no-log-init -r -u $UNIFI_UID -g $UNIFI_GID unifi \
 && /usr/local/bin/docker-build.sh

VOLUME ["/unifi", "${RUNDIR}"]

EXPOSE 6789/tcp 8080/tcp 8443/tcp 8880/tcp 8843/tcp 3478/udp

WORKDIR /unifi

HEALTHCHECK CMD /usr/local/bin/docker-healthcheck.sh || exit 1

# execute controller using JSVC like original debian package does
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["unifi"]

RUN [ "cross-build-end" ]
