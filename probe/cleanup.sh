#!/usr/bin/env bash
# Delete a user's upload directory
dir=$1
rm -rf /srv/uploads/$dir
eval "echo cleaned $dir"
