#!/bin/sh

# variables

username="user"
password="password"
share_name="Shared"
container_name="samba"

# creating shared directory if it doesn't exist

FILE=/volume1/share

if [ ! -d "$FILE" ]; then
    mkdir -p "$FILE"
    chmod 777 "$FILE"
fi

# starting the container

if [ "$(docker ps -a -q -f name=${container_name})" ]; then
  docker kill ${container_name}
  docker rm ${container_name}
fi

docker run --cgroupns=host --name ${container_name} -p 139:139 -p 445:445 -p 137:137/udp -p 138:138/udp -v "$FILE:/share" -d dperson/samba -n -u "${username};${password}" -s "${share_name};/share;yes;no;no;all;none;none;Shared files" -p -r -g "fruit:model = MacPro7,1@ECOLOR=226,226,224" -g "fruit:resource = xattr" -g "fruit:metadata = stream"