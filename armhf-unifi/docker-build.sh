#!/usr/bin/env bash

# fail on error
set -e


#Add repo for openjdk-8-jre-headless from stretch
echo "deb http://httpredir.debian.org/debian/ stretch main" | tee -a /etc/apt/sources.list

echo "Package: *\nPin: release a=stretch\nPin-Priority: -10\n\nPackage: *\nPin: release a=stable\nPin-Priority: 100" | tee /etc/apt/preferences

apt-get update
apt-get install -qy --no-install-recommends \
    openjdk-8-jre-headless \
    libcap2-bin

apt-key adv --keyserver hkps://keyserver.ubuntu.com --recv 06E85760C0A52C50 
echo 'deb http://www.ui.com/downloads/unifi/debian stable ubiquiti' | tee /etc/apt/sources.list.d/100-ubnt-unifi.list

apt update
apt install -y unifi
chown -R unifi:unifi /usr/lib/unifi
rm -rf /var/lib/apt/lists/*

rm -rf ${ODATADIR} ${OLOGDIR}
mkdir -p ${DATADIR} ${LOGDIR}
ln -s ${DATADIR} ${BASEDIR}/data
ln -s ${RUNDIR} ${BASEDIR}/run
ln -s ${LOGDIR} ${BASEDIR}/logs
rm -rf {$ODATADIR} ${OLOGDIR}
ln -s ${DATADIR} ${ODATADIR}
ln -s ${LOGDIR} ${OLOGDIR}
mkdir -p /var/cert ${CERTDIR}
ln -s ${CERTDIR} /var/cert/unifi
