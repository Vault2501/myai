FROM nginx:latest

COPY nginx.conf /etc/nginx/nginx.conf
COPY ssl/assets/ai.crt /etc/ssl/certs/ai.crt
COPY ssl/assets/ai.key /etc/ssl/private/ai.key
COPY www/index.html /www/data/index.html
