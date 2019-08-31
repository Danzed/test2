# Build:
# docker build -t aven-web-api/aven-web-api .
#
# Run:
# docker run -it aven-web-api/aven-web-api
#
# Compose:
# docker-compose up -d

FROM ubuntu:latest
LABEL maintainer="Daniel Hernandez <df.hernandez@hotmail.cl>"

# 80 = HTTP, 443 = HTTPS, 3000 = aven-web-api server, 35729 = livereload, 8080 = node-inspector
EXPOSE 80 443 3000 35729 8080 9000

# Set development environment as default
ENV NODE_ENV development

ENV MASTER_KEY $(MASTER_KEY)
ENV JWT_SECRET $(JWT_SECRET)
ENV SENDGRID_KEY $(SENDGRID_KEY)

# Install Utilities
RUN apt-get update -q  \
    && apt-get install -yqq \
    curl \
    git \
    ssh \
    gcc \
    make \
    build-essential \
    libkrb5-dev \
    sudo \
    apt-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash -
RUN sudo apt-get install -yq nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install aven-web-api Prerequisites
RUN npm install --quiet -g mocha karma-cli pm2 && npm cache clean --force

RUN mkdir -p /opt/aven-web-api/public/lib
WORKDIR /opt/aven-web-api

# Copies the local package.json file to the container
# and utilities docker container cache to not needing to rebuild
# and install node_modules/ everytime we build the docker, but only
# when the local package.json file changes.
# Install npm packages
COPY package.json /opt/aven-web-api/package.json
RUN npm install --quiet && npm cache clean --force

# Install bower packages
# COPY bower.json /opt/aven-web-api/bower.json
# COPY .bowerrc /opt/aven-web-api/.bowerrc
# RUN bower install --quiet --allow-root --config.interactive=false

COPY . /opt/aven-web-api

# Run aven-web-api server
CMD npm install && npm start