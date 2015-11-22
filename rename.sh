#!/bin/bash
REMOVE="test"		# escape characters on special characters.
MATCHING="*.mp3"

for file in ${MATCHING}; do
	mv "$file" "${file/$REMOVE/}"
done
