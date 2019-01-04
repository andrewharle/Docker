#!/bin/sh -ex

QEMU_VERSION="3.0.0+resin" QEMU_TARGET="arm"
QEMU_SHA256="47ae430b0e7c25e1bde290ac447a720e2ea6c6e78cd84e44847edda289e020a8"
QEMU_URL_TAG="v3.0.0%2Bresin"
QEMU_URL="https://github.com/resin-io/qemu/releases/download/${QEMU_URL_TAG}/qemu-${QEMU_VERSION}-${QEMU_TARGET}.tar.gz"

curl -SL  $QEMU_URL -o qemu-${QEMU_VERSION}-${QEMU_TARGET}.tar.gz
echo "${QEMU_SHA256}  qemu-${QEMU_VERSION}-${QEMU_TARGET}.tar.gz" > qemu-${QEMU_VERSION}-${QEMU_TARGET}.tar.gz.sha256sum
sha256sum -c qemu-${QEMU_VERSION}-${QEMU_TARGET}.tar.gz.sha256sum
rm -f qemu-${QEMU_VERSION}-${QEMU_TARGET}.tar.gz.sha256sum

rm -f qemu-${QEMU_TARGET}-static
tar --strip 1 -xzf qemu-${QEMU_VERSION}-${QEMU_TARGET}.tar.gz
rm -f qemu-${QEMU_VERSION}-${QEMU_TARGET}.tar.gz
