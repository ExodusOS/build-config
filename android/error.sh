#!/bin/bash

set -eu
echo "--- Uploading logs on error"
echo "failures/${DEVICE}/${BUILD_UUID}/"
scp /tmp/android-sync.log melles1991@frs.sourceforge.net:/home/frs/project/exodusos/ExodusOS/${DEVICE}/logs/
scp /tmp/android-build.log melles1991@frs.sourceforge.net:/home/frs/project/exodusos/ExodusOS/${DEVICE}/logs/
