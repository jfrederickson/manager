FROM node:carbon as builder

ARG CLIENT_ID
ARG API_ROOT
ARG LOGIN_ROOT
ARG LISH_ROOT
ARG WEBENGAGE_ID
ARG GA_ID
ARG APP_ROOT

COPY . /opt/manager

RUN npm install yarn
RUN apt-get update && apt-get -y install jq

WORKDIR /opt/manager/components
RUN yarn link
WORKDIR /opt/manager
RUN yarn
RUN yarn link linode-components

RUN bin/vars.sh

RUN yarn run build:webpack


FROM nginx
COPY --from=builder /opt/manager/dist /usr/share/nginx/html/static
COPY --from=builder /opt/manager/assets /usr/share/nginx/html/assets
COPY --from=builder /opt/manager/index.html /usr/share/nginx/html/index.html
