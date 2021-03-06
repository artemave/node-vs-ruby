#!/bin/bash

cnt=0

until vagrant destroy &> /dev/null; do
  if ((cnt > 30)); then
    echo "Failed to destroy build server! This may get expensive."
    exit 1
  fi

  echo "Trying to destroy build server."
  ((cnt++))
  sleep 15
done

echo "Build server successfully destroyed."

SSHKEYID=$(curl -s -H "API-Key: $VULTR_TOKEN" https://api.vultr.com/v1/sshkey/list | jq --raw-output '.[] | select(.name == "vagrant") .SSHKEYID')

if ! curl -H "API-Key: $VULTR_TOKEN" https://api.vultr.com/v1/sshkey/destroy --data "SSHKEYID=$SSHKEYID"; then
  echo "Failed to remove SSH key from vultr. No further builds will pass."
  exit 1
fi

echo "SSH key removed from vultr."
