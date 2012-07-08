##Prelude

This doc teaches you how to write an Operating System (OS) from scratch.

##Table Of Contents

* ####[Introduction](#introduction)

* ####[Initial Development Environment Setup](#initial-dev-env-setup)
    * [Installing GCC - the GNU Compiler Collection](#install-gcc)
      * [Windows](#install-gcc-win)
      * [Mac](#install-gcc-mac)
      * [Linux](#install-gcc-linux)
    * [Creating a Cross Compiler](#create-cross-compiler)
         * [binutils](#compile-binutils)
         * [gmp](#compile-gmp)
         * [mpfr](#compile-mpfr)
         * [gcc](#compile-gcc)
      
<a name="introduction">Introduction</a>
---
[TODO]

<a name="initial-dev-env-setup">Initial Development Environment Setup</a>
---
[TODO]

###<a name="install-gcc">Installing GCC - the GNU Compiler Collection</a>

####<a name="install-gcc-win">Installing GCC in Windows</a>
For Windows we will be using MinGW. You can download the mingw-get installer from http://sourceforge.net/projects/mingw/files/Installer/mingw-get-inst/.

Remember to check the following when installing MinGW.

   * C Compiler
   * C++ Compiler
   * MSYS Base System
   
Now you are ready to move on to the next step.

Note: In this tutorial you will be required to download some files from the internet, rather then opening browser and downloading,
you might want to install a command line tool called `wget` which will make downloading a lot easier from the shell. (Installing wget is optional.)

Open MinGW Shell then type the following command in the shell.

```bash
mingw-get install msys-wget
```

####<a name="install-gcc-mac">Installing GCC in Mac</a>
GCC comes bundle with Xcode in Mac. If you don't want to install the full Xcode you can download a seperate package 
called - `Command Line Tools for Xcode` from the Apple developers site. (You will need a free Apple ID inorder to download it.)
You can download it from http://developer.apple.com/downloads (Search for command to filter the results. For this tutorial
we will be using `Command Line Tools for Xcode - June 2012` which is around 147mb compared to Xcode which is around 1.8gb+.)

You can uninstall the command line tools in mac using the following command.

```bash
sudo /Library/Developer/Shared/uninstall-devtools --mode=all
```

####<a name="install-gcc-linux">Installing GCC in Linux</a>
For linux we will be using [Ubuntu](http://www.ubuntu.com/) so some commands like installing packages will be
specific to Ubuntu.

Type the following command in the terminal to install `binutils` and `gcc`. You might require root privilages to install
or perform certain tasks. In Ubuntu it can be performed by prepending `sudo` infront of the command. You might be asked to
enter your password.

```bash
sudo apt-get install build-essential
sudo apt-get install m4
sudo apt-get install bison
```

When asked to install type `Y` and press enter.

###<a name="create-cross-compiler">Creating a Cross Compiler</a>

Our OS will be using the elf binary format targeting x86 machines. We will thus need a compiler that can target elf and x86
machines. By default the binutils and gcc compiler you installed can target only the format the os is on. This means we need
to create our own specific builds of `binutils` and `gcc` that is capable of targeting x86 which is capable for generating x86
binaries.

####<a name="compile-binutils">Compiling binutils</a>
Download the source code of `binutils` which can be found at http://ftp.gnu.org/gnu/binutils/ or use the following command.

```bash
mkdir build-binutils
cd build-binutils
wget http://ftp.gnu.org/gnu/binutils/binutils-2.22.tar.gz
```

Extract binutils-2.22.tar.gz

```bash
tar -vxzf binutils-2.22.tar.gz
```

Configure binutils

```bash
binutils-2.22/configure --prefix=/usr/local/cross --target=i586-elf --disable-nls
```

`--diable-nls` tells to exclude native language support when creating binutils.

Compiling binutils

```bash
make all
```

Installing binutils to /usr/local/cross folder

```bash
make install
```

####<a name="compile-gmp">Compiling gmp</a>
Since gcc depends on gmp, we need to compile gmp first.
Download the source code of `gmp` which can be found at http://ftp.gnu.org/gnu/gmp/gmp-5.0.5.tar.xz or
use the following command.

```bash
mkdir build-gmp
cd build-gmp
wget http://ftp.gnu.org/gnu/gmp/gmp-5.0.5.tar.xz
```

Extract gmp-5.0.5.tar.xz

```bash
tar Jxf gmp-5.0.5.tar.xz
```

Configure gmp

```bash
gmp-5.0.5/configure
```

Compiling gmp

```bash
make all
```

Installing gmp

```bash
make install
```

####<a name="compile-mpfr">Compiling mpfr</a>
Since gcc depends on mpfr, we need to compile mpfr first.
Download the source code of `mpfr` which can be found at http://ftp.gnu.org/gnu/mpfr/mpfr-3.1.1.tar.xz or
use the following command.

```bash
mkdir build-mpfr
cd build-mpfr
wget http://ftp.gnu.org/gnu/mpfr/mpfr-3.1.1.tar.xz
```

Extract mpfr-3.1.1.tar.xz

```bash
tar Jxf mpfr-3.1.1.tar.xz
```

Configure mpfr

```bash
mpfr-3.1.1/configure
```

Compiling mpfr

```bash
make all
```

Installing mpfr

```bash
make install
```

####<a name="compile-mpc">Compiling mpc</a>
Since gcc depends on mpc, we need to compile mpc first.
Download the source code of `mpc` which can be found at http://www.multiprecision.org/mpc/download/mpc-0.8.2.tar.gz or
use the following command.

```bash
mkdir build-mpc
cd build-mpc
wget http://www.multiprecision.org/mpc/download/mpc-0.8.2.tar.gz
```

Extract mpc-0.8.2.tar.gz

```bash
tar xzvf mpc-0.8.2.tar.gz
```

Configure mpc

```bash
mpc-0.8.2.tar.gz/configure
```

Compiling mpc

```bash
make all
```

Installing mpc

```bash
make install
```

####<a name="compile-gcc">Compiling gcc</a>
Note: You need to have [compiled version of gmp](#compile-gmp), [compiled version of mpfr](#compile-mpfr) and 
[compiled version of mpc](#compile-mpc) before compiling gcc.

Download the source code of `gcc` which can be found at http://ftp.gnu.org/gnu/gcc/gcc-4.7.1/gcc-4.7.1.tar.gz or
use the following command.

```bash
mkdir build-gcc
cd build-gcc
wget http://ftp.gnu.org/gnu/gcc/gcc-4.7.1/gcc-4.7.1.tar.gz
```

Extract gcc-4.7.1.tar.gz

```bash
tar -vxzf gcc-4.7.1.tar.gz
```

Configure gcc

```bash
gcc-4.7.1/configure --prefix=/usr/local/cross --target=i586-elf --disable-nls --enable-languages=c,c++ --without-header
```

`--diable-nls` tells to exclude native language support when creating gcc.

[TODO]
