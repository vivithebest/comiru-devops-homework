FROM nginx:stable-alpine

COPY docker/nginx/nginx.conf /tmp/nginx.template.conf

COPY public /var/www/html/public

EXPOSE 80
ENV PHP_FPM_HOST=localhost

ENTRYPOINT envsubst '$PHP_FPM_HOST' < /tmp/nginx.template.conf > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'
