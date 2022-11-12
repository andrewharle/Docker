# unifi-controller for armhf

This is a modified version of the image provided by [linuxserver/unifi-controller](https://github.com/linuxserver/docker-unifi-controller). In particular:

 * MongoDB is not bundled, instead an external container is used in the docker-compose file;
 * temurin-8 is used instead of OpenJDK8;
 * s6-overlay v3 is used.

The [Unifi-controller](https://www.ubnt.com/enterprise/#unifi) software is a powerful, enterprise wireless software engine ideal for high-density client deployments requiring low latency and high uptime performance.

## Supported Architectures

The architectures supported by this image are:

| Architecture | Available | Tag |
| :----: | :----: | ---- |
| armhf| ✅ | TBC |

## Application Setup

The webui is at https://ip:8443, setup with the first run wizard.

For Unifi to adopt other devices, e.g. an Access Point, it is required to change the inform IP address. Because Unifi runs inside Docker by default it uses an IP address not accessible by other devices. To change this go to Settings > System Settings > Controller Configuration and set the Controller Hostname/IP to a hostname or IP address accessible by your devices. Additionally the checkbox "Override inform host with controller hostname/IP" has to be checked, so that devices can connect to the controller during adoption (devices use the inform-endpoint during adoption).

In order to manually adopt a device take these steps:

```
ssh ubnt@$AP-IP
set-inform http://$address:8080/inform
```

The default device password is `ubnt`. `$address` is the IP address of the host you are running this container on and `$AP-IP` is the Access Point IP address.

When using a Security Gateway (router) it could be that network connected devices are unable to obtain an ip address. This can be fixed by setting "DHCP Gateway IP", under Settings > Networks > network_name, to a correct (and accessable) ip address.

## Usage

Please use **docker-compose** for this image, as it relies upon an external monogdb server container. Note that a dummy mongodb package is installed to satisfy unifi dependencies.

s6-overlay v3 is used as the init system here. **There are various tools available in the s6 suite for process inspection**

**Some logs may be stored in the container under /var/logs**

## Parameters

As per the docker-compose file, the system.properties file contains configuration for the unifi controller and can be passed at container initialisation see `compose-root/defaults/system.properties`. Note that the `unifi.db.*` parameters are relevant insofar as an external mongodb instance is concerned.

Container images are configured using parameters passed at runtime. These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 8443` | Unifi web admin port |
| `-p 3478/udp` | Unifi STUN port |
| `-p 10001/udp` | Required for AP discovery |
| `-p 8080` | Required for device communication |
| `-p 1900/udp` | Required for `Make controller discoverable on L2 network` option |
| `-p 8843` | Unifi guest portal HTTPS redirect port |
| `-p 8880` | Unifi guest portal HTTP redirect port |
| `-p 6789` | For mobile throughput test |
| `-p 5514/udp` | Remote syslog port |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Europe/London` | Specify a timezone to use (e.g. Europe/London) - [see list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) |

## Umask for running applications

For all of our images we provide the ability to override the default umask settings for services started within the containers using the optional `-e UMASK=022` setting.
Keep in mind umask is not chmod it subtracts from permissions based on it's value it does not add. Please read up [here](https://en.wikipedia.org/wiki/Umask) before asking for support.

## User / Group Identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`, to find yours use `id user` as below:

```bash
  $ id username
    uid=1000(dockeruser) gid=1000(dockergroup) groups=1000(dockergroup)
```

## Useful commands

* Shell access whilst the container is running: `docker exec -it unifi-controller /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f unifi-controller`
* container version number
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' unifi-controller`
* image version number
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' lscr.io/linuxserver/unifi-controller:latest`

## Updating Info

### Via Docker Compose

* Update all images: `docker-compose pull`
  * or update a single image: `docker-compose pull unifi-controller`
* Let compose update all containers as necessary: `docker-compose up -d`
  * or update a single container: `docker-compose up -d unifi-controller`
* You can also remove the old dangling images: `docker image prune`

### Via Docker Run

* Update the image: `docker pull lscr.io/linuxserver/unifi-controller:latest`
* Stop the running container: `docker stop unifi-controller`
* Delete the container: `docker rm unifi-controller`
* Recreate a new container with the same docker run parameters as instructed above (if mapped correctly to a host folder, your `/config` folder and settings will be preserved)
* You can also remove the old dangling images: `docker image prune`

### Via Watchtower auto-updater (only use if you don't remember the original parameters)

* Pull the latest image at its tag and replace it with the same env variables in one run:

  ```bash
  docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower \
  --run-once unifi-controller
  ```

* You can also remove the old dangling images: `docker image prune`

**Note:** We do not endorse the use of Watchtower as a solution to automated updates of existing Docker containers. In fact we generally discourage automated updates. However, this is a useful tool for one-time manual updates of containers where you have forgotten the original parameters. In the long term, we highly recommend using [Docker Compose](https://docs.linuxserver.io/general/docker-compose).

## Building locally

If you want to make local modifications to these images for development purposes or just to customize the logic:

```bash
sudo apt update && sudo apt install -y apt-cacher-ng
sudo service apt-cacher-ng start

git clone https://github.com/andrewharle/Docker.git
cd unifi

# Get the IP addr of the apt-cacher-ng server e.g. ip addr
docker build \
  -t unifi_temp \
  --progress=plain \
  --add-host=aptcacher.internal:172.24.48.164 .
```
