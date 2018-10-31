# v4.9.1, NPM_VERSION=2
# v6.14.4, NPM_VERSION=3
# v8.12.0, NPM_VERSION=6, YARN_VERSION=latest
# v10.13.0, NPM_VERSION=6, YARN_VERSION=latest

FROM node:8.12.0-alpine

RUN apk add --no-cache \
  bash \
  git \
  tar \
  openssh-client \
  openssh \
  zip \
  curl \
  coreutils \
  grep

RUN npm i -g npm
