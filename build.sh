#!/usr/bin/env bash
set -e

cd $(dirname "${BASH_SOURCE[0]}")
today=$(date +"%Y%m%d")
git filter-branch --tree-filter 'rm -f output/arch_rootfs*' --prune-empty master
docker run --privileged -t -i -v $(pwd)/output:/output -v $(pwd)/script:/opt/mkimage jprjr/arch /opt/mkimage/mkimage-arch.sh $today

# If the above command completed then we're good to update the dockerfile
# and push to git
cp dockersrc/Dockerfile output/Dockerfile
sed -i "s/##DATE##/$today/" output/Dockerfile
git add output/Dockerfile && git commit -m "Updating Dockerfile $today"
git add output/arch_rootfs_$today.tar.gz && git commit -m "Updating rootfs $today"
