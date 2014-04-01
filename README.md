# docker-jprjr/arch

This is a script for building a small filesystem based off of Arch Linux.

You'll need Docker installed to build this image. I use the `base/arch` image to
build this root fs.

To build this, run `build.sh` - I can't figure out how to get `expect` to work
properly, so this means you'll have to hit "n" and enter a few times while this
builds.

Once it does, you can use the Dockerfile in the `output` folder.

The mkimage-arch.sh script is based off [dotcloud's script](https://github.com/dotcloud/docker/blob/master/contrib/mkimage-arch.sh).
