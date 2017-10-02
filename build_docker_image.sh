#!/bin/bash -x

if [ "${1}" == "dev" ]; then
    BUILDMODE="dev"
    ANCHORESRCHOME="/root/"
    if [ -d "${ANCHORESRCHOME}/wheelhouse" ]; then
	ANCHOREWHEELHOUSE="${ANCHORESRCHOME}/wheelhouse"
    fi
    DOCKERFILE="scripts/dockerfiles/Dockerfile.dev"
    TAG="anchore-engine:dev"
else
    BUILDMODE="latest"
    DOCKERFILE="Dockerfile"
    TAG="anchore-engine:latest"
fi

#if [ "$1" == "use-cache" ]
#then
#	echo "Building with cache usage allowed"
#	cache_directive=""
#else
#	echo "Building with no cache usage. To enable usage pass value 'use-cache' as param one to this script"
#	cache_directive="--no-cache"
#fi

set -e

# CACHE_DIRECTIVE="--no-cache"
CACHE_DIRECTIVE=""

mkdir -p /tmp/anchore-engine-build
rm -rf /tmp/anchore-engine-build/anchore-engine/
cp -a ${DOCKERFILE} /tmp/anchore-engine-build/Dockerfile

cd /tmp/anchore-engine-build/

if [ "${BUILDMODE}" == "dev" ]; then
    rsync -azP /${ANCHORESRCHOME}/anchore-engine/ /tmp/anchore-engine-build/anchore-engine/
    rsync -azP /${ANCHORESRCHOME}/anchore-cli/ /tmp/anchore-engine-build/anchore-cli/
    rsync -azP /${ANCHORESRCHOME}/anchore/ /tmp/anchore-engine-build/anchore/
else
    git clone git@github.com:anchore/anchore-engine.git
fi


WHEELVOLUME=""
if [ ! -z "$ANCHOREWHEELHOUSE" ]; then
    if [ -d "$ANCHOREWHEELHOUSE" ]; then
	WHEELVOLUME="-v ${ANCHOREWHEELHOUSE}:/wheelhouse"
    fi
fi

cd /tmp/anchore-engine-build && docker build -t ${TAG} ${CACHE_DIRECTIVE} ${WHEELVOLUME} . && docker tag ${TAG} anchore/${TAG}
