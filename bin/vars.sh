#!/bin/bash
set -x -e

echo "export const clientId = \"$CLIENT_ID\";" >> src/secrets.js

version=$(/usr/bin/jq '.version' package.json | sed 's/"//g')
perl -pi -w -e "s@/static/common.js@/static/common.js?v=$version@g" index.html
perl -pi -w -e "s@/static/bundle.js@/static/bundle.js?v=$version@g" index.html
