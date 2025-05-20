FROM nginx:stable-alpine

COPY docker/nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY public /var/www/html/public

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
