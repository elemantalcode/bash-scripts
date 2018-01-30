#!/bin/bash

# This works by trawling the .rpmcache/ tree to find an exact RPM name
#  finds the SHA and trawls the filesystem to recover the exact RPM
#  with the correct name.
#
# Needs lots of work - written in 7 minutes

# Set the artifactory recover mount
basename="/mnt/disk1/artifactory/data"

# Set the destination recover directory
recoverdir="/storage/recover"

mkdir -p $recoverdir

if [ -z "$1" ]; then
    echo "Supply an RPM name"
    exit 99
fi

filename="$1"

cd $basename

# Find rpmcache name and directory attached
fullrpmname=`find ./ -name "$1" | cut -d'.' -f2-`
rpmdirname=`dirname "$basename/$fullrpmname" | tail -1`

# Grab the SHA to find the actual file
cd "$rpmdirname"
sha=`cat "$filename" | jq -r '.sha1Digest'`

cd $basename

fullshaname=`find ./ -name "$sha" | cut -d'.' -f2-`
shadirname=`dirname "$basename/$fullshaname" | tail -1`

cd "$shadirname"

# Copy the SHA named file to the actual RPM name and
# change perms to be able to import correctly as arti user
cp $sha $recoverdir/$filename
chown artifactory: $recoverdir/*
