
This document details the build process for linux.

## Makefiles

The makefiles for linux are:
```
./source/Makefile
./source/Makefile-main.mk
```

## Key Requirements

* Bash 4.4
* make 4.1
* gcc

## Prerequisites

The linux build requires 3 external support tools:
* sdcc
* cpm
* hex2bin

The can be install with

`make install-prereq`

This will be wget/cloned the require code into `linuxbuild\prereq\...` and compile the tools.

During all make operation, the path is overriden to ensure these versions of the tools are used.

## Building.

All make targets are accessed thru the main `Makefile` in `source`.  So to make roms, binaries, etc:

```
cd source
make <target>
```

To invoke in parallel for a quicker build time:
```
cd source
make <target> -j -O
```


Where target is the desired target - eg `make tools -j -O` to make all the general tool binaries.

All key outputs are places in the `bin` directory.

The targets of interest are:

```
clean:                Remove the bin directory
install-prereq:       Install required tooling (sdcc, hex2bin, cpm) into (linuxtools/prereq)
help:                 Display this help message

                      Main targets

tools:                Build tools binaries into the bin directory
hdddsk:               Build a FAT12 hard disk image containing nextor.sys, command2.com and all other tools
fdddsk:               Build a FAT12 floppy disk image containing nextor.sys, command2.com
sunrise:              Build the sunrise rom image
```

### Make process

The linux build process starts by symlinking all source files, from their various sub directories, into the `bin/working` directory.  With any name clashes are resolved by renaming some files with a prefix).

All intermediate files are also placed in the `bin/working` directory.  With the main outputs copied to `bin`

See the `linuxtools/prep.sh` script for more details of the symlinking structure and name conflict resolutions.

