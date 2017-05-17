FROM php:7.0
MAINTAINER Luke Cousins
RUN apt-get update -yqq && \
  apt-get install -yqq git zip curl libicu-dev libcurl4-openssl-dev libfreetype6-dev libgd-dev libmcrypt-dev libjpeg62-turbo-dev libpng12-dev libbz2-dev php-pear mysql-client \
  && rm -r /var/lib/apt/lists/*

# PHP Extensions
RUN docker-php-ext-install mcrypt
RUN docker-php-ext-install zip
RUN docker-php-ext-install bz2
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install curl
RUN docker-php-ext-install intl
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install gd
RUN docker-php-ext-configure bcmath
RUN docker-php-ext-install bcmath

# Old attempt
#RUN pecl install apcu-5.1.8 && echo extension=apcu.so > /usr/local/etc/php/conf.d/apcu.ini
#RUN docker-php-ext-enable apcu

RUN pecl install apcu-5.1.8
RUN docker-php-ext-enable apcu
RUN pecl install apcu_bc-1.0.3
RUN docker-php-ext-enable apc
RUN rm -f /usr/local/etc/php/conf.d/docker-php-ext-apc.ini
RUN rm -f /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini

# Copy in APC config
COPY php/*.ini /usr/local/etc/php/conf.d/
  
# Install Xdebug
RUN curl -fsSL 'https://xdebug.org/files/xdebug-2.4.1.tgz' -o xdebug.tar.gz \
    && mkdir -p xdebug \
    && tar -xf xdebug.tar.gz -C xdebug --strip-components=1 \
    && rm xdebug.tar.gz \
    && ( \
    cd xdebug \
    && phpize \
    && ./configure --enable-xdebug \
    && make -j$(nproc) \
    && make install \
    ) \
    && rm -r xdebug \
    && docker-php-ext-enable xdebug

# Memory Limit
RUN echo "memory_limit=-1" > $PHP_INI_DIR/conf.d/memory-limit.ini

# Time Zone
RUN echo "date.timezone=Europe/London" > $PHP_INI_DIR/conf.d/date_timezone.ini

# Install phpunit, the tool that we will use for testing
RUN curl -Lo /usr/local/bin/phpunit https://phar.phpunit.de/phpunit.phar \
  && chmod +x /usr/local/bin/phpunit

# Display PHP version
RUN php --version

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Display Composer version
RUN composer --version

