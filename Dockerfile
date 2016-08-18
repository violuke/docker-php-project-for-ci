FROM php:7.0
MAINTAINER Luke Cousins <luke@cou.si>
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y yqq git zip curl libicu-dev libcurl4-openssl-dev libfreetype6-dev libgd-dev \
  && rm -r /var/lib/apt/lists/*

# PHP Extensions
RUN docker-php-ext-install mcrypt zip bz2 mbstring pdo_mysql curl intl \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install gd \
  && docker-php-ext-configure bcmath \
  && docker-php-ext-install bcmath
  
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
