# Indigo - Docker Testing

Testing repo for running [Indigo](https://github.com/laws-africa/indigo) on [Docker](https://docker.io) via Docker Compose:

Note, this is a work in progress, currently not working, installation succeeds, however pending some revisions.

This assumes that you have installed docker and docker-compose on a system with no external facing ip (On purpose, ideal deployment would have Docker Server hosted behind a reverse proxy).

## The process so far

Clone from GIT and enter:

```bash
git clone https://github.com/buff0k/indigo-docker
```

```bash
cd indigo-docker
```

Generate a .env using example-env

```bash
mv example-env .env
```

Set up the .env file with your settings:

```bash
nano .env
```
Edit the file to match your desired settings.

Deploy to Docker using Docker Compose:

```bash
docker-compose up
```

Configure Superuser:

```bash
docker exec -it indigo_app_1 /src/indigopython manage.py createsuperuser
```
