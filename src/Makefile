# Makefile targets:
#
# all/install   build and install the NIF
# clean         clean build products and intermediates
#
# Variables to override:
#
# BUILD         where to store intermediate files (defaults to src directory)
# PREFIX        path to the installation direction (defaults to ./priv)
#
# CC            		C compiler
# CROSSCOMPILE			crosscompiler prefix, if any
# CFLAGS				compiler flags for compiling all C files
# ERL_CFLAGS			additional compiler flags for files using Erlang header files
# ERL_EI_INCLUDE_DIR 	include path to ei.h (Required for crosscompile)
# ERL_EI_LIBDIR 		path to libei.a (Required for crosscompile)
# LDFLAGS				linker flags for linking all binaries
# ERL_LDFLAGS			additional linker flags for projects referencing Erlang libraries

ifeq ($(MIX_COMPILE_PATH),)
	$(error MIX_COMPILE_PATH should be set by elixir_make!)
endif

PREFIX = $(MIX_COMPILE_PATH)/../priv
BUILD  = $(MIX_COMPILE_PATH)/../obj

SRC_PATH = src/teensy_loader_cli
MakeDirCommand = mkdir

OS ?= LINUX
#OS ?= WINDOWS
#OS ?= MACOSX
#OS ?= BSD

# uncomment this to use libusb on Macintosh, instead of Apple's HID manager via IOKit
# this is technically not the "correct" way to support Macs, but it's been reported to
# work.
#USE_LIBUSB ?= YES

.PHONY: all clean 
all: $(PREFIX)/teensy_loader_cli

ifeq ($(OS), LINUX)  # also works on FreeBSD
CC ?= gcc
CFLAGS ?= -O2 -Wall
$(PREFIX)/teensy_loader_cli: $(SRC_PATH)/teensy_loader_cli.c
	$(MakeDirCommand) -p ${PREFIX}
	$(CC) $(CFLAGS) -s -DUSE_LIBUSB -o $(PREFIX)/teensy_loader_cli $(SRC_PATH)/teensy_loader_cli.c -lusb $(LDFLAGS)


else ifeq ($(OS), WINDOWS)
CC ?= i586-mingw32msvc-gcc
CFLAGS ?= -O2 -Wall
teensy_loader_cli.exe: $(SRC_PATH)/teensy_loader_cli.c
	$(MakeDirCommand) ${PREFIX}
	$(CC) $(CFLAGS) -s -DUSE_WIN32 -o $(PREFIX)/teensy_loader_cli.exe $(SRC_PATH)/teensy_loader_cli.c -lhid -lsetupapi -lwinmm


else ifeq ($(OS), MACOSX)
ifeq ($(USE_LIBUSB), YES)
CC ?= gcc
CFLAGS ?= -O2 -Wall
$(PREFIX)/teensy_loader_cli: $(SRC_PATH)/teensy_loader_cli.c
	$(MakeDirCommand) -p ${PREFIX}
	$(CC) $(CFLAGS) -s -DUSE_LIBUSB -DMACOSX -o $(PREFIX)/teensy_loader_cli $(SRC_PATH)/teensy_loader_cli.c -lusb -I /usr/local/include -L/usr/local/lib
	 
else
CC ?= gcc
SDK ?= $(shell xcrun --show-sdk-path)
#SDK ?= /Developer/SDKs/MacOSX10.6.sdk  # the old way...
#SDK = /Developer_xcode32/SDKs/MacOSX10.5.sdk  # the very old way!
#CC = /Developer_xcode32/usr/bin/gcc-4.0
#CFLAGS = -O2 -Wall -arch i386 -arch ppc
CFLAGS ?= -O2 -Wall
$(PREFIX)/teensy_loader_cli: $(SRC_PATH)/teensy_loader_cli.c
ifeq ($(SDK),)
	$(error SDK was not found. To use this type of compilation please install Xcode)
endif
	$(CC) $(CFLAGS) -DUSE_APPLE_IOKIT -isysroot $(SDK) -o $(PREFIX)/teensy_loader_cli $(SRC_PATH)/teensy_loader_cli.c -Wl,-syslibroot,$(SDK) -framework IOKit -framework CoreFoundation

endif

else ifeq ($(OS), BSD)  # works on NetBSD and OpenBSD
CC ?= gcc
CFLAGS ?= -O2 -Wall
$(PREFIX)/teensy_loader_cli: $(SRC_PATH)/teensy_loader_cli.c
	$(MakeDirCommand) -p ${PREFIX}
	$(CC) $(CFLAGS) -s -DUSE_UHID -o $(PREFIX)/teensy_loader_cli $(SRC_PATH)/teensy_loader_cli.c
endif


clean:
	rm -f teensy_loader_cli teensy_loader_cli.exe*