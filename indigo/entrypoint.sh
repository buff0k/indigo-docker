#!/bin/sh

if [ "$DATABASE" = "postgres" ]
then
    echo "Waiting for postgres..."

    while ! nc -z database 5432; do
      sleep 0.1
    done

    echo "PostgreSQL started"
fi

cd /src/indigo
python manage.py makemigrations
python manage.py migrate
python manage.py update_countries_plus
python manage.py loaddata languages_data.json
python manage.py compilescss
python manage.py collectstatic --noinput -i docs -i \*scss 2>&1

exec "$@"
