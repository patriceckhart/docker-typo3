FROM php:8.1-fpm-alpine3.17

ENV COMPOSER_VERSION 2.5.1
ENV HOME /application

RUN set -x \
	&& apk update \
	&& apk add bash \
	&& apk add nano gettext git nginx tar curl postfix mariadb-client optipng freetype libjpeg-turbo-utils icu-dev openssh pwgen build-base && apk add --virtual libtool freetype-dev libpng-dev libjpeg-turbo-dev yaml-dev libssh2-dev php81-pecl-igbinary graphicsmagick \
	&& docker-php-ext-configure gd --with-freetype --with-jpeg \
	&& docker-php-ext-install \
		gd \
		pdo \
		pdo_mysql \
		opcache \
		intl \
		exif \
	&& apk add --no-cache --virtual .deps imagemagick imagemagick-libs imagemagick-dev autoconf postgresql-dev \
	&& deluser www-data \
	&& delgroup cdrw \
	&& addgroup -g 80 www-data \
	&& adduser -u 80 -G www-data -s /bin/bash -D www-data -h /application \
	&& rm -Rf /home/www-data \
	&& sed -i -e "s#listen = 9000#listen = /var/run/php-fpm.sock#" /usr/local/etc/php-fpm.d/zz-docker.conf \
	&& echo "clear_env = no" >> /usr/local/etc/php-fpm.d/zz-docker.conf \
	&& echo "listen.owner = www-data" >> /usr/local/etc/php-fpm.d/zz-docker.conf \
	&& echo "listen.group = www-data" >> /usr/local/etc/php-fpm.d/zz-docker.conf \
	&& echo "listen.mode = 0660" >> /usr/local/etc/php-fpm.d/zz-docker.conf \
	&& sed -i -e "s#listen = 127.0.0.1:9000#listen = /var/run/php-fpm.sock#" /usr/local/etc/php-fpm.d/www.conf \
	&& chown 80:80 -R /var/lib/nginx \
	&& apk add --no-cache redis \
	&& pecl install redis && docker-php-ext-enable redis \
	&& docker-php-ext-install bcmath && docker-php-ext-enable bcmath \
	&& docker-php-ext-install sysvsem && docker-php-ext-enable sysvsem \
	&& apk add imap-dev krb5-dev \
	&& docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
	&& docker-php-ext-install imap \
	&& docker-php-ext-enable imap \
	&& docker-php-ext-install pdo pdo_pgsql \
	&& apk add \
	       libzip-dev \
	       zip \
	&& docker-php-ext-install zip \
	&& pecl install imagick-beta && docker-php-ext-enable --ini-name 20-imagick.ini imagick \
	&& cd /tmp \
	&& pecl install ssh2-1.3.1 && docker-php-ext-enable ssh2 \
	&& pecl install yaml && echo "extension=yaml.so" > /usr/local/etc/php/conf.d/ext-yaml.ini && docker-php-ext-enable --ini-name ext-yaml.ini yaml \
	&& curl -o /tmp/composer-setup.php https://getcomposer.org/installer && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --version=${COMPOSER_VERSION} && rm -rf /tmp/composer-setup.php \
	&& echo 'StrictHostKeyChecking no' >> /etc/ssh/ssh_config \
	&& rm -rf /var/cache/apk/* \
	&& apk add tzdata \
	&& apk del tzdata \
	&& rm -rf /var/cache/apk/* \
	&& mkdir -p /run/nginx

EXPOSE 80 443

WORKDIR /application
COPY /root-files/ /root-files/
RUN chown -R www-data:www-data /application && chmod -R g+rwx /application && chmod -R 775 /application && chown -R www-data:www-data /root-files && chmod -R 775 /root-files

ENTRYPOINT ["/root-files/init.sh"]
