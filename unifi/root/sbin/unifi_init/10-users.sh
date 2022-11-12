#!/usr/bin/with-contenv bash

PUID=${PUID:-999}
PGID=${PGID:-999}

groupmod -o -g "$PGID" $UNAME
usermod -o -u "$PUID" $UNAME

echo "
-------------------------------------
User $UNAME uid:    $(id -u $UNAME)
User $UNAME gid:    $(id -g $UNAME)
-------------------------------------
"
chown $UNAME:$UNAME /app
chown $UNAME:$UNAME /config
chown $UNAME:$UNAME /defaults