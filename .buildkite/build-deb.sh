#!/bin/bash
set -e
shopt -s extglob


docker pull 276514628126.dkr.ecr.ap-southeast-2.amazonaws.com/trustybuild


orig_dir="$(pwd)"
tmp_dir=/tmp/build-${BUILDKITE_JOB_ID}
rm -rf "${tmp_dir}"
mkdir -p "${tmp_dir}/src"
cd "${tmp_dir}"
cp -R "${orig_dir}"/* "src/"

DEBFULLNAME="buildkite-ci"
NAME="buildkite-ci"
EMAIL=trustybuild@koordinates.com
DEBEMAIL=trustybuild@koordinates.com


docker run --rm=true  \
           -v "${tmp_dir}:/kx/source" \
           -e GPG_KEY="${APT_GPG_KEY}" \
           -e DEBFULLNAME \
           -e NAME \
           -e EMAIL \
           -e DEBEMAIL \
           -w "/kx/source/src" \
           276514628126.dkr.ecr.ap-southeast-2.amazonaws.com/trustybuild \
           dch \
              -u medium --distribution trusty --package "spatialindex" \
              --newversion "1.8.5+kx-${BUILDKITE_BUILD_NUMBER}" "${BUILDKITE_BRANCH}:${BUILDKITE_COMMIT}"


docker run --rm=true  \
           -v "${tmp_dir}:/kx/source" \
           -e GPG_KEY="${APT_GPG_KEY}" \
           -e DEBEMAIL \
           -w "/kx/source/src" \
           276514628126.dkr.ecr.ap-southeast-2.amazonaws.com/trustybuild \
           /bin/bash -c "/kx/buildscripts/build_binary_package.sh"

cd "${orig_dir}"
rm -rf build-trusty
mkdir -p build-trusty
cp "${tmp_dir}"/build-trusty/*.deb "${orig_dir}"/build-trusty
rm -rf "${tmp_dir}"
