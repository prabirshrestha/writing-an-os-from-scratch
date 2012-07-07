##Prelude

This doc teaches you how to write an Operating System (OS) from scratch.

##Table Of Contents

* ####[Introduction](#introduction)

* ####[Initial Development Environment Setup](#initial-dev-env-setup)
    * [Installing GCC - the GNU Compiler Collection](#install-gcc)
      * [Windows](#install-gcc-win)
      * [Mac](#install-gcc-mac)
      * [Linux](#install-gcc-linux)

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

####<a name="install-gcc-linux">Installing GCC in Linux</a>
For linux we will be using [Slitaz](http://www.slitaz.org/) so some commands like installing packages will be
specific to Slitaz. *SliTaz is a linux based open source and free operating system providing a fully featured desktop 
or server in less than 35 MB.*

Type the following commands in the terminal to install `binutils` and `gcc`.

```bash
su
tazpkg get-install binutils
tazpkg get-install gcc
exit
```
