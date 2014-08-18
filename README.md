# docker-jprjr/arch

This is a script for building a small filesystem based off of Arch Linux.

You'll need Docker installed to build this image. I use my `jprjr/arch` image to
build this root fs.

To build this, run `build.sh` - once it's finished, you should have a Dockerfile
and root filesystem image in the `output` folder.

The mkimage-arch.sh script is based off [dotcloud's script](https://github.com/dotcloud/docker/blob/master/contrib/mkimage-arch.sh).

This also has the [s6](http://skarnet.org/software/s6/) init system installed,
it makes it really easy to build proper setup + init scripts for your software.
