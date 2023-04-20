#!/bin/bash

if [ -f "/application/startup-root.sh" ]; then

	echo "Run custom startup-root.sh from repository ..."

	sh /application/startup-root.sh

fi
