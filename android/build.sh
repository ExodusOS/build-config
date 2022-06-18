#!/bin/bash
set -eo pipefail
echo "--- Setup"
rm /tmp/android-*.log || true
export USE_CCACHE="1"
export CCACHE_EXEC=/usr/bin/ccache
ccache -s
export PYTHONDONTWRITEBYTECODE=true
export BUILD_ENFORCE_SELINUX=1
export BUILD_NO=
unset BUILD_NUMBER
export OVERRIDE_TARGET_FLATTEN_APEX=true 
#TODO(zif): convert this to a runtime check, grep "sse4_2.*popcnt" /proc/cpuinfo
export CPU_SSE42=false
# Following env is set from build
# VERSION
# DEVICE
# TYPE
# RELEASE_TYPE
# EXP_PICK_CHANGES

if [ -z "$BUILD_UUID" ]; then
  export BUILD_UUID=$(uuidgen)
fi

if [ -z "$TYPE" ]; then
  export TYPE=userdebug
fi

OFFSET="10000000"
export BUILD_NUMBER=$(($OFFSET + $BUILDKITE_BUILD_NUMBER))

echo "--- Syncing"

mkdir -p /exodus/${VERSION}/.repo/local_manifests
cd /exodus/${VERSION}
rm -rf .repo/local_manifests/*
if [ -f /exodus/setup.sh ]; then
    source /exodus/setup.sh
fi
# catch SIGPIPE from yes
yes | repo init -u https://github.com/exodusos/android.git -b ${VERSION} -g default,-darwin || if [[ $? -eq 141 ]]; then true; else false; fi

echo "Syncing"
repo sync --detach --current-branch --no-tags --force-remove-dirty --force-sync -j32 > /tmp/android-sync.log 2>&1
. build/envsetup.sh


echo "--- clobber"
rm -rf out

echo "--- breakfast"
breakfast lineage_${DEVICE}-${TYPE}

if [[ "$TARGET_PRODUCT" != lineage_* ]]; then
    echo "Breakfast failed, exiting"
    exit 1
fi

if [ "$RELEASE_TYPE" '==' "experimental" ]; then
  if [ -n "$EXP_PICK_CHANGES" ]; then
    repopick $EXP_PICK_CHANGES
  fi
fi
echo "--- Building"
export OVERRIDE_TARGET_FLATTEN_APEX=true 
mka otatools-package target-files-package dist > /tmp/android-build.log

echo "--- Uploading"
scp out/dist/*target_files*.zip melles1991@frs.sourceforge.net:/home/frs/project/exodusos/ExodusOS/${DEVICE}/

echo "--- cleanup"
rm -rf out
