# --- Stage 1: Builder ---
FROM composer:2.8 AS builder

WORKDIR /app
COPY . .
RUN composer install

# --- Stage 2: PHP-FPM Runtime ---
FROM php:8.2-fpm-alpine
RUN apk update && apk add --no-cache \
    curl-dev \ 
    libpng-dev \
    libzip-dev \
    libxml2-dev \
    icu-dev \
    zip \
    && docker-php-ext-install pdo pdo_mysql zip intl opcache gd exif bcmath

# COPY docker/php-fpm/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY docker/php/error_log.ini /usr/local/etc/php/php.ini

WORKDIR /var/www/html
COPY . .
COPY --from=builder /app/vendor /var/www/html/vendor

RUN mv .env.example .env \
    && touch database/database.sqlite \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

ENV LOG_CHANNEL=stderr

EXPOSE 9000

CMD ["sh", "-c", "php artisan migrate --force && php-fpm"]
