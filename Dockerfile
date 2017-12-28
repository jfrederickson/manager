# Linode Manager images are not suitable for upload to Docker Hub as most of
# its configuration options are set at build-time (particularly the client ID).
# A public image would therefore not be very useful, as the client ID is used
# to look up the OAuth redirect URI, and is therefore specific to your
# deployment.

FROM node:carbon as builder

ARG CLIENT_ID
ARG API_ROOT=https://api.linode.com/v4
ARG LOGIN_ROOT=https://login.linode.com
ARG LISH_ROOT=wss://lish.linode.com
ARG APP_ROOT
ARG WEBENGAGE_ID
ARG GA_ID

COPY . /opt/manager

RUN npm install yarn
RUN apt-get update && apt-get -y install jq

WORKDIR /opt/manager
RUN yarn

RUN bin/pre-build.sh

RUN yarn run build:webpack


FROM nginx:alpine

COPY --from=builder /opt/manager/dist /usr/share/nginx/html/static
COPY --from=builder /opt/manager/assets /usr/share/nginx/html/assets
COPY --from=builder /opt/manager/index.html /usr/share/nginx/html/index.html
