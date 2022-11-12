# Mongodb for armhf works only with buster
# Example build command= docker build -t mongodb_armhf . --progress=plain --add-host=aptcacher.internal:172.24.59.173 | tee build.log
FROM --platform=linux/arm/v7 baseimage_temp_buster

#https://specs.opencontainers.org/image-spec/annotations/
LABEL org.opencontainers.image.authors="Andrew Harle <46223597+andrewharle@users.noreply.github.com>"
LABEL org.opencontainers.image.title="Mongodb for armhf"
LABEL org.opencontainers.image.source=https://github.com/andrewharle/Docker

ENV UNAME mongodb

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN set -eux; \
	groupadd --gid 999 --system $UNAME; \
	useradd --uid 999 --system --gid $UNAME --home-dir /data/db $UNAME; \
	mkdir -p /data/db /data/configdb; \
	chown -R $UNAME:$UNAME /data/db /data/configdb

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		jq \
		numactl \
	; \
	if ! command -v ps > /dev/null; then \
		apt-get install -y --no-install-recommends procps; \
	fi; \
	rm -rf /var/lib/apt/lists/*

# grab "js-yaml" for parsing mongod's YAML config files (https://github.com/nodeca/js-yaml/releases)
ENV JSYAML_VERSION 3.13.1
ENV JSYAML_SHA256 01680f005cd0b602240745d28b8bd439bc41001875f92413252ec0e50983e921

RUN set -ex; \
	apt-get update; \
	if ! command -v gpg > /dev/null; then \
		apt-get install -y --no-install-recommends gnupg dirmngr; \
	fi; \
	rm -rf /var/lib/apt/lists/*; \
	wget -O /js-yaml.js "https://github.com/nodeca/js-yaml/raw/${JSYAML_VERSION}/dist/js-yaml.js"; \
    echo "$JSYAML_SHA256 js-yaml.js" | sha256sum --check; \
	#Smoke test
	gosu nobody true

RUN mkdir /docker-entrypoint-initdb.d
    
RUN set -ex; \
    mkdir -p /etc/apt/keyrings && \
    gpg --no-default-keyring --keyring /etc/apt/keyrings/andrewharle_repo.gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys $ANDREWHARLE_GITHUB_KEY && \
    echo "deb [arch=armhf signed-by=/etc/apt/keyrings/andrewharle_repo.gpg] https://andrewharle.github.io/REPO/debian buster experimental" | tee /etc/apt/sources.list.d/100-andrewharle_repo.list

    # Allow build-time overrides (eg. to build image with MongoDB Enterprise version)
    # Options for MONGO_PACKAGE: mongodb-org OR mongodb-enterprise
    # Options for MONGO_REPO: repo.mongodb.org OR repo.mongodb.com
    # Example: docker build --build-arg MONGO_PACKAGE=mongodb-enterprise --build-arg MONGO_REPO=repo.mongodb.com .
    
ENV MONGO_PACKAGE=mongodb
ENV MONGO_VERSION 1:4.0.*

RUN set -x \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y ${MONGO_PACKAGE}=$MONGO_VERSION \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/mongodb \
    && mv /etc/mongodb.conf /etc/mongodb.conf.orig

# add local files
RUN set -ex; \
    echo "**** Copying Local Files****"
COPY root/ /
RUN chmod +x /sbin/mongo_init/*.sh

VOLUME /data/db /data/configdb

# ensure that if running as custom user that "mongosh" has a valid "HOME"
# https://github.com/docker-library/mongo/issues/524
ENV HOME /data/db

RUN set -ex; \
    echo "C"
COPY docker-entrypoint.sh /usr/local/bin/
ENV S6_CMD_ARG0 "docker-entrypoint.sh"

EXPOSE 27017
CMD ["mongod"]
ENTRYPOINT ["/init"]