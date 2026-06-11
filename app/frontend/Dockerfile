FROM nginx:1.27-alpine
COPY index.html /usr/share/nginx/html/index.html
COPY entrypoint.sh /docker-entrypoint.d/40-inject-api-url.sh
RUN chmod +x /docker-entrypoint.d/40-inject-api-url.sh
EXPOSE 80
