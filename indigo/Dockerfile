FROM python:3.10-slim-bookworm
# Install required dependencies
RUN apt update && apt install git build-essential nodejs npm netcat-traditional poppler-utils fontconfig xfonts-base xfonts-75dpi fop --no-install-recommends -y
# Testing cron
# cron
# Testing Removed apt packages:
# make libjpeg62-turbo libssl-dev zlib1g-dev libyaml-dev libreadline-dev libncurses5-dev libgdbm-dev libpq-dev libncursesw5-dev liblzma-dev libffi-dev libbz2-dev install xfonts-utils xfonts-encodings libpoppler-dev bison sqlite3 libsqlite3-dev llvm autoconf xz-utils tk-dev ghostscript
# Install Python Dependencies
RUN pip install --upgrade wheel pip setuptools
RUN pip install gevent==21.8.0 gunicorn==20.1.0 psycopg2-binary
# Install NodeJS Dependencies
RUN npm install -g sass
# Clone Indigo Production 18.0.0
RUN git clone --branch v18.0.0 --single-branch https://github.com/laws-africa/indigo /src/indigo
# Change to indigo folder
WORKDIR /src/indigo
# Run setup.py to install Indigo dependencies
RUN pip install -e .
# Enable Background Tasks & Setup Cron Job
RUN sed -i "s/'NOTIFICATION_EMAILS_BACKGROUND': False,/'NOTIFICATION_EMAILS_BACKGROUND': True,/" ./indigo/settings.py
# RUN crontab -l | { cat; echo "*/5 * * * * python /src/indigo/manage.py process_tasks --duration 180"; } | crontab -
# Compile Indigo Static Files
RUN python manage.py compilescss
RUN python manage.py collectstatic --noinput -i docs -i \*scss 2>&1
# Generate SSL Certificates
RUN openssl req -new -x509 -days 3500 -nodes -subj /C=ZA/ST=irrelevant/L=irrelevant/O=irrelevant/OU=irrelevant/CN=Indigo -out /root/server.crt -keyout /root/server.key
COPY entrypoint.sh .
RUN sed -i 's/\r$//g'  entrypoint.sh
RUN chmod +x  entrypoint.sh
ENTRYPOINT ["/src/indigo/entrypoint.sh"]
