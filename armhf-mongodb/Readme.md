# Original sources

[https://github.com/docker-library/mongo](https://github.com/docker-library/mongo)

[https://github.com/docker-library/docs/tree/master/mongo](https://github.com/docker-library/docs/tree/master/mongo)

## Principal Modifications

* armhf image for MongoDB 4.0
* s6-overlay init (mongodb is still the entrypoint/CMD)
* Log filtering for mongo

# How to use this image

## Start a `mongo` server instance

```console
$ docker run --name some-mongo -d mongo:tag
```

... where `some-mongo` is the name you want to assign to your container and `tag` is the tag specifying the MongoDB version you want. See the list above for relevant tags.

## Connect to MongoDB from another Docker container

The MongoDB server in the image listens on the standard MongoDB port, `27017`, so connecting via Docker networks will be the same as connecting to a remote `mongod`. The following example starts another MongoDB container instance and runs the `mongosh` (use `mongo` with `4.x` versions) command line client against the original MongoDB container from the example above, allowing you to execute MongoDB statements against your database instance:

```console
$ docker run -it --network some-network --rm mongo mongosh --host some-mongo test
```

... where `some-mongo` is the name of your original `mongo` container.

## ... via [`docker stack deploy`](https://docs.docker.com/engine/reference/commandline/stack_deploy/) or [`docker-compose`](https://github.com/docker/compose)

Example `stack.yml` for `mongo`:

```yaml
mongodb-server:
  platform: linux/arm/v7
  image: mongodb_armhf
  restart: on-failure:3
  environment:
    - MONGO_OUT_FILTER_PATTERN=^.* I NETWORK.*received client metadata from.*
    - PUID=1000
    - PGID=1000
  #expose - Available only to other containers within this compose
  expose:
    - 27017
  # https://www.mongodb.com/docs/v4.0/reference/configuration-options/
  command: ["--storageEngine=mmapv1", "--smallfiles", "--quiet", "--nojournal"]
  # From: https://github.com/docker-library/healthcheck/blob/master/mongo/docker-healthcheck
  healthcheck:
    test: ["CMD", "mongo", "--quiet", "mongodb-server/test", "--eval", 'quit(db.runCommand({ ping: 1 }).ok ? 0 : 2)']
    interval: 30s
    timeout: 10s
    retries: 3
    start_period: 15s
```

Run `docker stack deploy -c stack.yml mongo` (or `docker-compose -f stack.yml up`).

## Container shell access and viewing MongoDB logs

The `docker exec` command allows you to run commands inside a Docker container. The following command line will give you a bash shell inside your `mongo` container:

```console
$ docker exec -it some-mongo bash
```

The MongoDB Server log is available through Docker's container log:

```console
$ docker logs some-mongo
```

Additional logs are stored under `/var/log`

## Configuration

See the [MongoDB manual](https://docs.mongodb.com/manual/) for information on using and configuring MongoDB for things like replica sets and sharding.

## Customize configuration without configuration file

Most MongoDB configuration can be set through flags to `mongod`. The entrypoint of the image is created to pass its arguments along to `mongod`. See below an example of setting MongoDB to use a different [threading and execution model](https://docs.mongodb.com/manual/reference/program/mongod/#cmdoption-mongod-serviceexecutor) via `docker run`.

```console
$ docker run --name some-mongo -d mongo --serviceExecutor adaptive
```

And here is the same with a `docker-compose.yml` file

```yaml
version: '3.1'
services:
  mongo:
    image: mongo
    command: --serviceExecutor adaptive
```

To see the full list of possible options, check the MongoDB manual on [`mongod`](https://docs.mongodb.com/manual/reference/program/mongod/) or check the `--help` output of `mongod`:

```console
$ docker run -it --rm mongo --help
```

## Using a custom MongoDB configuration file

For a more complicated configuration setup, you can still use the MongoDB configuration file. `mongod` does not read a configuration file by default, so the `--config` option with the path to the configuration file needs to be specified. Create a custom configuration file and put it in the container by either creating a custom Dockerfile `FROM mongo` or mounting it from the host machine to the container. See the MongoDB manual for a full list of [configuration file](https://docs.mongodb.com/manual/reference/configuration-options/) options.

For example, `/my/custom/mongod.conf` is the path to the custom configuration file. Then start the MongoDB container like the following:

```console
$ docker run --name some-mongo -v /my/custom:/etc/mongo -d mongo --config /etc/mongo/mongod.conf
```

## Environment Variables

When you start the `mongo` image, you can adjust the initialization of the MongoDB instance by passing one or more environment variables on the `docker run` command line. Do note that none of the variables below will have any effect if you start the container with a data directory that already contains a database: any pre-existing database will always be left untouched on container startup.

### <ins>`MONGO_INITDB_ROOT_USERNAME`, `MONGO_INITDB_ROOT_PASSWORD`</ins>

These variables, used in conjunction, create a new user and set that user's password. This user is created in the `admin` [authentication database](https://docs.mongodb.com/manual/core/security-users/#user-authentication-database) and given [the role of `root`](https://docs.mongodb.com/manual/reference/built-in-roles/#root), which is [a "superuser" role](https://docs.mongodb.com/manual/core/security-built-in-roles/#superuser-roles).

The following is an example of using these two variables to create a MongoDB instance and then using the `mongosh` cli (use `mongo` with `4.x` versions) to connect against the `admin` authentication database.

```console
$ docker run -d --network some-network --name some-mongo \
	-e MONGO_INITDB_ROOT_USERNAME=mongoadmin \
	-e MONGO_INITDB_ROOT_PASSWORD=secret \
	mongo

$ docker run -it --rm --network some-network mongo \
	mongosh --host some-mongo \
		-u mongoadmin \
		-p secret \
		--authenticationDatabase admin \
		some-db
> db.getName();
some-db
```

Both variables are required for a user to be created. If both are present then MongoDB will start with authentication enabled (`mongod --auth`).

Authentication in MongoDB is fairly complex, so more complex user setup is explicitly left to the user via `/docker-entrypoint-initdb.d/` (see the *Initializing a fresh instance* and *Authentication* sections below for more details).

### <ins>`MONGO_INITDB_DATABASE`</ins>

This variable allows you to specify the name of a database to be used for creation scripts in `/docker-entrypoint-initdb.d/*.js` (see *Initializing a fresh instance* below). MongoDB is fundamentally designed for "create on first use", so if you do not insert data with your JavaScript files, then no database is created.

### <ins>`$MONGO_OUT_FILTER_PATTERN`</ins>

The output from mongo can be filtered via awk by setting this environment variable.

For example it is useful to filter superflous connection logs generated by mongo e.g.

`2022-11-10T20:14:08.817+0000 I NETWORK  [conn1] received client metadata from 172.19.0.2:57450 conn1: ...`

by using `mawk` in the `docker-entrypoint.sh`

`$MONGO_OUT_FILTER_PATTERN` = `pattern="^.* I NETWORK.*received client metadata from.*"`

`mongo --$args | mawk -Winteractive -v` <ins>***`pattern=$MONGO_OUT_FILTER_PATTERN`***</ins> `'$0 !~ pattern {print "[MongoDB] " $0}'`

### <ins>`PUID`, `GUID`</ins>

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`, to find yours use `id user` as below:

```bash
  $ id username
    uid=1000(dockeruser) gid=1000(dockergroup) groups=1000(dockergroup)
```

## Docker Secrets

As an alternative to passing sensitive information via environment variables, `_FILE` may be appended to the previously listed environment variables, causing the initialization script to load the values for those variables from files present in the container. In particular, this can be used to load passwords from Docker secrets stored in `/run/secrets/<secret_name>` files. For example:

```console
$ docker run --name some-mongo -e MONGO_INITDB_ROOT_PASSWORD_FILE=/run/secrets/mongo-root -d mongo
```

Currently, this is only supported for `MONGO_INITDB_ROOT_USERNAME` and `MONGO_INITDB_ROOT_PASSWORD`.

# Initializing a fresh instance

When a container is started for the first time it will execute files with extensions `.sh` and `.js` that are found in `/docker-entrypoint-initdb.d`. Files will be executed in alphabetical order. `.js` files will be executed by `mongosh` (`mongo` on versions below 6) using the database specified by the `MONGO_INITDB_DATABASE` variable, if it is present, or `test` otherwise. You may also switch databases within the `.js` script.

# Authentication

As noted above, authentication in MongoDB is fairly complex (although disabled by default). For details about how MongoDB handles authentication, please see the relevant upstream documentation:

-	[`mongod --auth`](https://docs.mongodb.com/manual/reference/program/mongod/#cmdoption-mongod-auth)
-	[Security > Authentication](https://docs.mongodb.com/manual/core/authentication/)
-	[Security > Role-Based Access Control](https://docs.mongodb.com/manual/core/authorization/)
-	[Security > Role-Based Access Control > Built-In Roles](https://docs.mongodb.com/manual/core/security-built-in-roles/)
-	[Security > Enable Auth (tutorial)](https://docs.mongodb.com/manual/tutorial/enable-authentication/)

In addition to the `/docker-entrypoint-initdb.d` behavior documented above (which is a simple way to configure users for authentication for less complicated deployments), this image also supports `MONGO_INITDB_ROOT_USERNAME` and `MONGO_INITDB_ROOT_PASSWORD` for creating a simple user with [the role `root`](https://docs.mongodb.com/manual/reference/built-in-roles/#root) in the `admin` [authentication database](https://docs.mongodb.com/manual/core/security-users/#user-authentication-database), as described in the *Environment Variables* section above.

# Caveats

## Where to Store Data

Important note: There are several ways to store data used by applications that run in Docker containers. We encourage users of the `mongo` images to familiarize themselves with the options available, including:

-	Let Docker manage the storage of your database data [by writing the database files to disk on the host system using its own internal volume management](https://docs.docker.com/engine/tutorials/dockervolumes/#adding-a-data-volume). This is the default and is easy and fairly transparent to the user. The downside is that the files may be hard to locate for tools and applications that run directly on the host system, i.e. outside containers.
-	Create a data directory on the host system (outside the container) and [mount this to a directory visible from inside the container](https://docs.docker.com/engine/tutorials/dockervolumes/#mount-a-host-directory-as-a-data-volume). This places the database files in a known location on the host system, and makes it easy for tools and applications on the host system to access the files. The downside is that the user needs to make sure that the directory exists, and that e.g. directory permissions and other security mechanisms on the host system are set up correctly.

**WARNING (Windows & OS X)**: When running the Linux-based MongoDB images on Windows and OS X, the file systems used to share between the host system and the Docker container is not compatible with the memory mapped files used by MongoDB ([docs.mongodb.org](https://docs.mongodb.com/manual/administration/production-notes/#fsync---on-directories) and related [jira.mongodb.org](https://jira.mongodb.org/browse/SERVER-8600) bug). This means that it is not possible to run a MongoDB container with the data directory mapped to the host. To persist data between container restarts, we recommend using a local named volume instead (see `docker volume create`). Alternatively you can use the Windows-based images on Windows.

The Docker documentation is a good starting point for understanding the different storage options and variations, and there are multiple blogs and forum postings that discuss and give advice in this area. We will simply show the basic procedure here for the latter option above:

1.	Create a data directory on a suitable volume on your host system, e.g. `/my/own/datadir`.
2.	Start your `mongo` container like this:

	```console
	$ docker run --name some-mongo -v /my/own/datadir:/data/db -d mongo
	```

The `-v /my/own/datadir:/data/db` part of the command mounts the `/my/own/datadir` directory from the underlying host system as `/data/db` inside the container, where MongoDB by default will write its data files.

This image also defines a volume for `/data/configdb` [for use with `--configsvr` (see docs.mongodb.com for more details)](https://docs.mongodb.com/v3.4/reference/program/mongod/#cmdoption-configsvr).

## Creating database dumps

Most of the normal tools will work, although their usage might be a little convoluted in some cases to ensure they have access to the `mongod` server. A simple way to ensure this is to use `docker exec` and run the tool from the same container, similar to the following:

```console
$ docker exec some-mongo sh -c 'exec mongodump -d <database_name> --archive' > /some/path/on/your/host/all-collections.archive
```
