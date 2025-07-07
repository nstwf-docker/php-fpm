ARG VERSION=8.4

FROM php:${VERSION}-fpm-alpine

# define variables
ARG APP_PATH="/app"
ENV APP_PATH=${APP_PATH}

ARG USER="dev"
ARG USER_ID=1000
ARG GROUP_ID=1000

# add packages
RUN apk add --no-cache \
    $PHPIZE_DEPS \
    icu-dev \
    libxml2-dev \
    oniguruma-dev \
    libzip-dev \
    freetype-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    libxslt-dev \
    bzip2-dev \
    zlib-dev \
    curl

# install 'install-php-extensions' script
RUN curl -sSLf https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
     -o /usr/local/bin/install-php-extensions \
  && chmod +x /usr/local/bin/install-php-extensions

# install extensions
RUN install-php-extensions \
    bcmath \
    bz2 \
    calendar \
    exif \
    gd \
    intl \
    mysqli \
    pcntl \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    opcache \
    soap \
    sodium \
    sockets \
    xsl \
    zip \
    xdebug

# remove unused deps
RUN apk del $PHPIZE_DEPS

# install composer
RUN apk add --no-cache curl \
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && chmod +x /usr/local/bin/composer

# create user
RUN addgroup -g ${GROUP_ID} -S ${USER} \
  && adduser -u ${USER_ID} -D -S -G ${USER} ${USER} \
  && mkdir ${APP_PATH}  \
  && chown -R ${USER}:${USER} ${APP_PATH}

EXPOSE 9000

WORKDIR ${APP_PATH}

CMD ["php-fpm"]
