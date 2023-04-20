#!/usr/bin/env bash

export DOLLAR='$'
envsubst < /root-files/opt/nginx/etc/typo3.conf.template > /etc/nginx/http.d/default.conf
