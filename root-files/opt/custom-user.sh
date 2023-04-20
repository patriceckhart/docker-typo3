#!/bin/bash

if [ -f "/application/startup.sh" ]; then

	echo "Run custom startup.sh from repository ..."

	sh /application/startup.sh

fi
