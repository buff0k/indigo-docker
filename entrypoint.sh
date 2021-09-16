#!/bin/sh


echo "Initializing postgres db..."

while ! nc -z db 5432; do
  sleep 1
done

echo "postgres database has initialized successfully"
fi

exec "$@"
