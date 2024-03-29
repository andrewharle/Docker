#!/usr/bin/env bash
set -e

# create our folders
mkdir -p \
    /config/{data,logs,run}


# create symlinks for config
symlinks=( \
/usr/lib/unifi/data \
/usr/lib/unifi/logs \
/usr/lib/unifi/run )

for i in "${symlinks[@]}"
do
[[ -L "$i" && ! "$i" -ef /config/"$(basename "$i")"  ]] && unlink "$i"
[[ ! -L "$i" ]] && ln -s /config/"$(basename "$i")" "$i"
done

if [[ ! -e /config/data/system.properties ]]; then
    cp /defaults/system.properties /config/data
fi

# if grep -q "xmx" /config/data/system.properties && grep -q "xms" /config/data/system.properties; then

#     if [[ $MEM_LIMIT == "default" ]]; then
#         echo "*** Setting Java memory limit to default ***"
#         sed -i "/unifi.xmx=.*/d" /config/data/system.properties
#     elif [[ -n $MEM_LIMIT ]]; then
#         echo "*** Setting Java memory limit to $MEM_LIMIT ***"
#         sed -i "s/unifi.xmx=.*/unifi.xmx=$MEM_LIMIT/" /config/data/system.properties 
#     fi

#     if [[ $MEM_STARTUP == "default" ]]; then
#         echo "*** Setting Java memory minimum to default ***"
#         sed -i "/unifi.xms=.*/d" /config/data/system.properties
#     elif [[ -n $MEM_STARTUP ]]; then
#         echo "*** Setting Java memory minimum to $MEM_STARTUP ***"
#         sed -i "s/unifi.xms=.*/unifi.xms=$MEM_STARTUP/" /config/data/system.properties
#     fi

# elif grep -q "xmx" /config/data/system.properties; then

#     if [[ $MEM_LIMIT == "default" ]]; then
#         echo "*** Setting Java memory limit to default ***"
#         sed -i "/unifi.xmx=.*/d" /config/data/system.properties
#     elif [[ -n $MEM_LIMIT ]]; then
#         echo "*** Setting Java memory limit to $MEM_LIMIT ***"
#         sed -i "s/unifi.xmx=.*/unifi.xmx=$MEM_LIMIT/" /config/data/system.properties
#     fi

#     if [[ -n $MEM_STARTUP ]]; then
#         echo "*** Setting Java memory minimum to $MEM_STARTUP ***"
#         echo "unifi.xms=$MEM_STARTUP" >> /config/data/system.properties
#     fi

# elif grep -q "xms" /config/data/system.properties; then

#     if [[ $MEM_STARTUP == "default" ]]; then
#         echo "*** Setting Java memory minimum to default ***"
#         sed -i "/unifi.xms=.*/d" /config/data/system.properties
#     elif [[ -n $MEM_STARTUP ]]; then
#         echo "*** Setting Java memory minimum to $MEM_STARTUP ***"
#         sed -i "s/unifi.xms=.*/unifi.xms=$MEM_STARTUP/" /config/data/system.properties
#     fi

#     if [[ -n $MEM_LIMIT ]]; then
#         echo "*** Setting Java memory limit to $MEM_LIMIT ***"
#         echo "unifi.xmx=$MEM_LIMIT" >> /config/data/system.properties 
#     fi

# else

#     if [[ -n $MEM_LIMIT ]]; then
#         echo "*** Setting Java memory limit to $MEM_LIMIT ***"
#         echo "unifi.xmx=$MEM_LIMIT" >> /config/data/system.properties 
#     fi

#     if [[ -n $MEM_STARTUP ]]; then
#         echo "*** Setting Java memory minimum to $MEM_STARTUP ***"
#         echo "unifi.xms=$MEM_STARTUP" >> /config/data/system.properties
#     fi

# fi

# permissions
chown -R unifi:unifi /config /usr/lib/unifi
