FROM nginx:alpine as build

RUN apk add --update \
    wget
    
ARG HUGO_VERSION="0.76.0"
RUN wget --quiet "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz" && \
    tar xzf hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
    rm -r hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
    mv hugo /usr/bin

COPY ./ /site
WORKDIR /site
# ARG BASE_URL="http\:\/\/ecs.dominicandevops.blog"
RUN sed 's/BASEURL_PLACEHOLDER/http\:\/\/ecs.dominicandevops.blog/g' config.toml >config.toml.new && mv config.toml.new config.toml
RUN hugo --config=config.toml

#Copy static files to Nginx
FROM nginx:alpine
COPY --from=build /site/public /usr/share/nginx/html
# COPY default.conf /etc/nginx/conf.d/default.conf
# COPY beyondcoio/fullchain.pem /etc/ssl/cert.pem
# COPY beyondcoio/privkey.pem /etc/ssl/key.pem
# RUN chmod 400 /etc/ssl/cert.pem && chmod 400 /etc/ssl/key.pem
# COPY beyondcoio/bcc.csr /etc/ssl/cert.csr
# COPY beyondcoio/bcc.key /etc/ssl/key.key
# RUN chmod 400 /etc/ssl/cert.csr && chmod 400 /etc/ssl/key.key

# gen new csr
# openssl req -newkey rsa:4096 -keyout bcc.key -out bcc.csr
WORKDIR /usr/share/nginx/html

# 576893435749.dkr.ecr.us-east-1.amazonaws.com/ddevopsblog:v1.0.0