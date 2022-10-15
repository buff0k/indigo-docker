FROM python:3.8-slim-bullseye
# Install Ruby 2.7 from official Ruby Dockerfile - https://github.com/docker-FROM debian:bullseye-slim
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		bzip2 \
		ca-certificates \
		libffi-dev \
		libgmp-dev \
		libssl-dev \
		libyaml-dev \
		procps \
		zlib1g-dev \
	; \
	rm -rf /var/lib/apt/lists/*

# skip installing gem documentation
RUN set -eux; \
	mkdir -p /usr/local/etc; \
	{ \
		echo 'install: --no-document'; \
		echo 'update: --no-document'; \
	} >> /usr/local/etc/gemrc

ENV LANG C.UTF-8
ENV RUBY_MAJOR 2.7
ENV RUBY_VERSION 2.7.6
ENV RUBY_DOWNLOAD_SHA256 54dcd3044726c4ab75a9d4604720501442b229a3aed6a55fe909567da8807f24

# some of ruby's build scripts are written in ruby
#   we purge system ruby later to make sure our final image uses what we just built
RUN set -eux; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		bison \
		dpkg-dev \
		libgdbm-dev \
		ruby \
		autoconf \
		g++ \
		gcc \
		libbz2-dev \
		libgdbm-compat-dev \
		libglib2.0-dev \
		libncurses-dev \
		libreadline-dev \
		libxml2-dev \
		libxslt-dev \
		make \
		wget \
		xz-utils \
	; \
	rm -rf /var/lib/apt/lists/*; \
	\
	wget -O ruby.tar.xz "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR%-rc}/ruby-$RUBY_VERSION.tar.xz"; \
	echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.xz" | sha256sum --check --strict; \
	\
	mkdir -p /usr/src/ruby; \
	tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1; \
	rm ruby.tar.xz; \
	\
	cd /usr/src/ruby; \
	\
# hack in "ENABLE_PATH_CHECK" disabling to suppress:
#   warning: Insecure world writable dir
	{ \
		echo '#define ENABLE_PATH_CHECK 0'; \
		echo; \
		cat file.c; \
	} > file.c.new; \
	mv file.c.new file.c; \
	\
	autoconf; \
	gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
	./configure \
		--build="$gnuArch" \
		--disable-install-doc \
		--enable-shared \
	; \
	make -j "$(nproc)"; \
	make install; \
	\
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark > /dev/null; \
	find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec ldd '{}' ';' \
		| awk '/=>/ { print $(NF-1) }' \
		| sort -u \
		| grep -vE '^/usr/local/lib/' \
		| xargs -r dpkg-query --search \
		| cut -d: -f1 \
		| sort -u \
		| xargs -r apt-mark manual \
	; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	\
	cd /; \
	rm -r /usr/src/ruby; \
# verify we have no "ruby" packages installed
	if dpkg -l | grep -i ruby; then exit 1; fi; \
	[ "$(command -v ruby)" = '/usr/local/bin/ruby' ]; \
# rough smoke test
	ruby --version; \
	gem --version; \
	bundle --version

# don't create ".bundle" in all our apps
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_SILENCE_ROOT_WARNING=1 \
	BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $GEM_HOME/bin:$PATH
# adjust permissions of a few directories for running "gem install" as an arbitrary user
RUN mkdir -p "$GEM_HOME" && chmod 777 "$GEM_HOME"

CMD [ "irb" ]

# Install Dependencies
RUN apt install git build-essential netcat poppler-utils --no-install-recommends -y
# Install wkhtmltopdf
ADD https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.bullseye_amd64.deb /tmp/wkhtmltox_0.12.6.1-2.bullseye_amd64.deb
RUN dpkg -i /tmp/wkhtmltox_0.12.6.1-2.bullseye_amd64.deb
# Install Python Dependencies
RUN pip install --upgrade pip setuptools wheel
RUN pip install gevent==21.8.0 gunicorn==20.1.0 psycopg2-binary==2.9.4
# Clone Indigo Stable 17.0.0
RUN git clone --branch v17.0.0 --single-branch https://github.com/laws-africa/indigo /src/indigo
WORKDIR /src/indigo
# Run setup.py to install Indigo dependencies
RUN pip install -e .
# Install Ruby Gems
RUN gem install bundler
RUN bundle install
# Compile Indigo Static Files
RUN python manage.py compilescss
RUN python manage.py collectstatic --noinput -i docs -i \*scss 2>&1
# Generate SSL Certificates
RUN openssl req -new -x509 -days 365 -nodes -subj /C=ZA/ST=irrelevant/L=irrelevant/O=irrelevant/OU=irrelevant/CN=Indigo -out /root/server.crt -keyout /root/server.key
# Add entrypoint
COPY ./entrypoint.sh .
RUN sed -i 's/\r$//g'  entrypoint.sh
RUN chmod +x  entrypoint.sh
ENTRYPOINT ["/src/indigo/entrypoint.sh"]
