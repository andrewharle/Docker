FROM andrewharle/armhf-debian-qemu:buster

RUN [ "cross-build-start" ]

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mongodb && useradd -r -g mongodb mongodb

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		apt-transport-https \
		ca-certificates \
		jq \
		numactl \
	; \
	if ! command -v ps > /dev/null; then \
		apt-get install -y --no-install-recommends procps; \
	fi; \
	rm -rf /var/lib/apt/lists/*

# grab gosu for easy step-down from root (https://github.com/tianon/gosu/releases)
ENV GOSU_VERSION 1.11
# grab "js-yaml" for parsing mongod's YAML config files (https://github.com/nodeca/js-yaml/releases)
ENV JSYAML_VERSION 3.13.1

RUN set -ex; \
	\
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
	wget -O /js-yaml.js "https://github.com/nodeca/js-yaml/raw/${JSYAML_VERSION}/dist/js-yaml.js"; \
# TODO some sort of download verification here
	\
	apt-get purge -y --auto-remove wget

RUN mkdir /docker-entrypoint-initdb.d

#Install dummy mongodb package
ENV GPG_KEY B6D32792566F0D55059947A90CDEA3BBE213DA29
RUN set -ex; \
    \
    apt-key adv --keyserver hkps://keyserver.ubuntu.com --recv $GPG_KEY \
    ; \
    echo "deb https://andrewharle.github.io/REPO/debian buster experimental" | tee -a /etc/apt/sources.list \
    ; \
    apt-key list

# Allow build-time overrides (eg. to build image with MongoDB Enterprise version)
# Options for MONGO_PACKAGE: mongodb-org OR mongodb-enterprise
# Options for MONGO_REPO: repo.mongodb.org OR repo.mongodb.com
# Example: docker build --build-arg MONGO_PACKAGE=mongodb-enterprise --build-arg MONGO_REPO=repo.mongodb.com .

ENV MONGO_PACKAGE=mongodb
ENV MONGO_VERSION 1:4.0.*

RUN set -x \
	&& apt-get update \
	&& apt-get install -y ${MONGO_PACKAGE}=$MONGO_VERSION \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/lib/mongodb

RUN mkdir -p /data/db /data/configdb \
	&& chown -R mongodb:mongodb /data/db /data/configdb
VOLUME /data/db /data/configdb

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat (3.4)
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 27017
CMD ["mongod"]

RUN [ "cross-build-end" ]
