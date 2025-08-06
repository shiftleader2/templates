#!/bin/bash
set -e

function upload_file {
  file=$(basename $2)
  filedata=$(echo $existing | jq ".[] | select(.name==\"${file}\")")

  if [[ $(echo $filedata | wc -c) -gt 10 ]]; then
    shasum=$(echo $filedata | jq -r '.sha256')
    if [[ $shasum == $(sha256sum $2 | awk '{ print $1 }') ]]; then
      echo No changes detected in the $1 $file. Skipping.
    else
      echo Updating the $1 file $file
      sl2 configfile set --content $2 $file
    fi
  else
    echo Creating the $1 file $file
    sl2 configfile create $file "" $group $1 $2
  fi
}

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <ResourceGroup>"
  exit 1
else
  group=$1
fi

if ! sl2 resourcegroup show $1 &> /dev/null; then
  echo "$1 does not look like a valid resourcegroup"
  exit 1
fi

existing=$(sl2 configfile list --format json )

for file in $(find TFTP-CONFIG -type f); do
  upload_file TFTP-CONFIG $file
done
for file in $(find INSTALLER-CONFIG -type f); do
  upload_file INSTALLER-CONFIG $file
done
for file in $(find POSTINSTALL-SCRIPT -type f); do
  upload_file POSTINSTALL-SCRIPT $file
done
for file in $(find FRAGMENT -type f); do
  upload_file FRAGMENT $file
done
