#!/usr/bin/env bash
set -e

# generate key
[[ ! -f /config/data/keystore ]] && \
    keytool -genkey -keyalg RSA -alias unifi -keystore /config/data/keystore \
    -storepass aircontrolenterprise -keypass aircontrolenterprise -validity 1825 \
    -keysize 4096 -dname "cn=unifi"

# permissions
chown unifi:unifi /config/data/keystore

# For future ref on importing certificates to the java key store https://github.com/jacobalberty/unifi-docker/blob/master/import_cert
