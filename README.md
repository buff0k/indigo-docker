# Indigo - Docker Testing

Testing repo for running [Indigo](https://github.com/OpenUpSA/indigo) on [Docker](https://docker.io) via Docker Compose:

Note, this is a work in progress, currently not working, installation succeeds, however pending some revisions to the ENV variables to get it working (Especially behind an NginX reverse Proxy).

This assumes that you have installed docker and docker-compose on a system with no external facing ip (On purpose, ideal deployment would have Docker Server hosted behind a reverse proxy).

## The process so far

Clone from GIT and enter:

```bash
git clone https://github.com/buff0k/indigo
```

```bash
cd example-indigo
```

Generate a .env using example-env

```bash
mv example-env .env
```

Set up the .env file with your settings (Note that Docker Compose will create a postgres database with the settings contained in the .env file):

```bash
nano .env
```

```bash
DATABASE_USER=your postgres database username
DATABASE_PASSWORD=something secure
DATABASE_NAME=name for your database
DISABLE_COLLECTSTATIC=1
DJANGO_DEBUG=False
DJANGO_SECRET_KEY=some random characters
AWS_ACCESS_KEY_ID=your AWS Acces Key
AWS_SECRET_ACCESS_KEY=your AWS secret
AWS_S3_BUCKET=your S3 bucket name
DJANGO_DEFAULT_FROM_EMAIL=your email address
DJANGO_EMAIL_HOST=your email smtp server
DJANGO_EMAIL_HOST_PASSWORD=your email password
DJANGO_EMAIL_HOST_PORT=your smtp port (normally 25)
DJANGO_EMAIL_HOST_USER=your email username
GOOGLE_ANALYTICS_ID=your google analytics id
SUPPORT_EMAIL=your support email address
NOTIFICATION_EMAILS_BACKGROUND=true
```

Deploy to Docker using Docker Compose:

```bash
docker-compose -up
```

Manually run post deploy tasks:

```bash
docker exec -it indigo_app_1 python manage.py migrate
```
```bash
docker exec -it indigo_app_1 python manage.py update_countries_plus
```
```bash
docker exec -it indigo_app_1 python manage.py loaddata languages_data.json.gz
```

```bash
docker exec -it indigo_app_1 python manage.py createsuperuser
```

## What is still missing:

After Initial Deploymeht, automatically run migrate && update_countries_plus && loaddata languages_data.json.gz

Disable Django security preventing working behind NginX (Set Host Name???)

Figure out why python manage.py runserver 0.0.0.0:8000 runs in development mode despite ENV DJANGO_DEBUG being set to false
