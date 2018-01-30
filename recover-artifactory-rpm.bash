#!/bin/bash

# This works by trawling the .rpmcache/ tree to find an exact RPM name
#  finds the SHA and trawls the filesystem to recover the exact RPM
#  with the correct name.

# Set the artifactory recover mount
basename="/mnt/disk1/artifactory/data"

# Set the destination recover directory
recoverdir="/storage/recover"

mkdir -p "$recoverdir"

if [[ -z "$1" ]]; then
    echo "Supply an RPM name"
    exit 1
fi

filename="$1"

if [[ -s "$recoverdir/$filename" ]]; then
    echo "$filename is already recovered!"
    exit 1
fi

# Find rpmcache name and directory attached, but only 'local'
fullrpmname=$( find $basename -name "$1" | grep local )
rpmdirname=$( dirname "$fullrpmname" )

# Grab the SHA to find the actual file
sha=$( jq -r '.sha1Digest' "$rpmdirname/$filename" )
fullshaname=$( find "$basename" -name "$sha" )
shadirname=$( dirname "$fullshaname" )

# Copy the SHA named file to the actual RPM name and
# change perms to be able to import correctly as arti user
cp "$shadirname/$sha" "$recoverdir/$filename"
chown artifactory: "$recoverdir"/*
