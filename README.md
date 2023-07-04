# Indigo - Docker Testing

Testing repo for running [Indigo](https://github.com/laws-africa/indigo) on [Docker](https://docker.io) via Docker Compose:

Note, this is a work in progress, currently not working, installation succeeds, however pending some revisions.

This assumes that you have installed docker and docker-compose on a system with no external facing ip (On purpose, ideal deployment would have Docker Server hosted behind a reverse proxy).

## How to install

Clone from GIT and enter:

```bash
git clone --branch v18.0.0 https://github.com/buff0k/indigo-docker
```

```bash
cd indigo-docker
```

Generate a .env using example-env

```bash
cp example-env .env
```
Set up the .env file with your settings:

```bash
nano .env
```
Edit the file to match your desired settings. Change the Variables, except DATABASE=postgres (This is currently part of the entrypoint file), to your own settings.

Deploy to Docker using Docker Compose:

```bash
docker-compose up
```
Once it is fully up, you can stop it with Ctrl+c, you still need to switch it to production mode.

Change the docker-compose file to production mode:
``` bash
nano docker-compose.yml
```
Edit thie line "DJANGO_DEBUG=true" to "DJANGO_DEBUG=false"

Now start up the Indigo Containers in production mode:
```bash
docker-compose up
``` 
If you want it to run as a daemon, add the -d switch to the end of the docker-compose up command.

Configure Superuser:

```bash
docker exec -it indigo-docker_indigo_1 python /src/indigo/manage.py createsuperuser
```

## Current Issues
1. Due to an issue with the indigo source, the initial databsae migration can only be run in debug mode, the above workaround solves this.
2. Still having some issues with the cron job for Background Tasks to run.
