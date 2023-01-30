#WSL: sudo service binfmt-support start
set platarch linux/amd64,linux/arm64,linux/arm/v7
buildah build --jobs=3 --platform=$platarch \
    --add-host=aptcacher.internal:(hostname -I | sed 's/ /\n/g' | head -1) \
    --manifest baseimage_temp_bullseye --build-arg RELEASE=bullseye .

buildah build --jobs=3 --platform=$platarch \
    --add-host=aptcacher.internal:(hostname -I | sed 's/ /\n/g' | head -1) \
    --manifest baseimage_temp_buster --build-arg RELEASE=buster .

#Done
    buildah build --layers=true --platform=$platarch \
    --add-host=aptcacher.internal:(hostname -I | sed 's/ /\n/g' | head -1) \
    --tag baseimage-bullseye --build-arg RELEASE=bullseye .

    buildah build --layers=true --platform=$platarch \
    --add-host=aptcacher.internal:(hostname -I | sed 's/ /\n/g' | head -1) \
    --tag baseimage-buster --build-arg RELEASE=buster .

    buildah build --layers=true --platform=$platarch \
    --add-host=aptcacher.internal:(hostname -I | sed 's/ /\n/g' | head -1) \
    --tag mongo-4.0 .

    buildah build --layers=true --platform=$platarch \
    --add-host=aptcacher.internal:(hostname -I | sed 's/ /\n/g' | head -1) \
    --tag unifi-controller .

    podman tag localhost/unifi-controller 192.168.2.194:8082/unifi-controller:latest
    podman tag localhost/mongo-4.0 192.168.2.194:8082/mongo-4.0:latest
    podman push --tls-verify=false 192.168.2.194:8082/unifi-controller:latest
    podman push --tls-verify=false 192.168.2.194:8082/unifi-controller:latest