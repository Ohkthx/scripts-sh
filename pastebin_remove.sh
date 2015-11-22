#!/bin/bash

# Created by: Royce || \x1p+2^]
# Syntax: pastebin_remove.sh

# # P R E P   W O R K # # 

uuid_f="${HOME}/uuid"		# UUID file + location.

cat ${HOME}/.uuid.bak | sort -nu > /tmp/uuid.bak  # Sorts the cached uuids and makes them unique
cp /tmp/uuid.bak ${HOME}/.uuid.bak		  # Copies the unique and sorted uuids to the backup file.

cat ${HOME}/uuid | sort -nu > /tmp/uuid.bak	  # Sorts and makes sure they are all unique (uuid file)
cp /tmp/uuid.bak ${uuid_f}			  # Copies it to the original.


while read line;
do
	echo "${line}" >> ${HOME}/.uuid.bak	  # Stores that uuid being removed into .uuid.bak for keeping.
	curl -X DELETE https://ptpb.pw/${line}	  # Deletes the PB from ptpb.pw/ based on the stored hash.
	line_num=`cat ${uuid_f} | grep -n -i "${line}" | cut -d':' -f1`  # Used to find the line number of the hash
	sed -i "${line_num}d" ${uuid_f}		  # Removes that line from the uuid file since the pb has been del.
	sleep 1					  # Makes sure that process is finished and for timing.
done < ${uuid_f}				  # Pipes to UUID file into the while statement. Each line becomes
						  #   the ${line} variable.
cat ${HOME}/.uuid.bak | sort -nu > /tmp/uuid.bak  # Cleanup again to make things unique.
cp /tmp/uuid.bak ${HOME}/.uuid.bak		  # Copies the cleaned up data back to the backup.
