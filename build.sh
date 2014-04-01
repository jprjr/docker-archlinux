#!/usr/bin/env bash
set -e

cd $(dirname "${BASH_SOURCE[0]}")
docker run --privileged -t -i -v $(pwd)/output:/output -v $(pwd)/script:/opt/mkimage jprjr/arch /opt/mkimage/mkimage-arch.sh

echo "Image built successfully!"
echo "Check "$(pwd)"/output for arch_rootfs.tar.xz"
