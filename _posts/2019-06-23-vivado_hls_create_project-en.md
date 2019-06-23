---
layout: posten
title: Using Vivado HLS with vivado_hls_create_project
description: "A brief description of IP generation and management with git"
date: 2019-06-23 22:00:00 +0900
lang: en
nav: post
category: Development tools
tags: [Vivado HLS, make]
---

# Introduction

vivado_hls_create_project is a tool for using Vivado HLS on command line.
Specifically, it generates Makefile and tcl scripts for using Vivado HLS only with make command.
Let's use it to create a simple IP!

# Generating Makefile and tcl scripts

Let's create an adder module for Zybo Z7-20.
Command `list` shows FPGAs to which vivado_hls_create_project deals with.

```
$ vivado_hls_create_project list
Board               Part
--------------------------------------------------
Alpha-Data          xc7vx690tffg1157-2
KU_Alphadata        xcku060-ffva1156-2-e
Xilinx_ZedBoard     xc7z020clg484-1
Xilinx_AC701        xc7a200tfbg676-2
Xilinx_KC705        xc7k325tffg900-2
Xilinx_KCU105       xcku040-ffva1156-2-e
Xilinx_KCU116       xcku5p-ffvb676-2-e
Xilinx_KCU1500      xcku115-flvb2104-2-e
Xilinx_VC707        xc7vx485tffg1761-2
Xilinx_VC709        xc7vx690tffg1761-2
Xilinx_VCU108       xcvu095-ffva2104-2-e
Xilinx_VCU110       xcvu190-flgc2104-2-e
Xilinx_VCU118       xcvu9p-flga2104-2L-e
Xilinx_VCU1525      xcvu9p-fsgd2104-2L-e
Xilinx_ZC702        xc7z020clg484-1
Xilinx_ZC706        xc7z045ffg900-2
Xilinx_ZCU102       xczu9eg-ffvb1156-2-i
Xilinx_ZCU106       xczu7ev-ffvc1156-2-i-es2
Xilinx_A-U200       xcu200-fsgd2104-2-e
Xilinx_A-U250       xcu250-figd2104-2L-e
Basys3              xc7a35t1cpg236-1
Genesys2            xc7k325t2ffg900c-1
Zybo                xc7z010clg400-1
Zybo_Z7_10          xc7z010clg400-1
Zybo_Z7_20          xc7z020clg400-1
```

If you can't find FPGAs you want to use, add a board name and etc. to `/path/to/Vivado/201x.x/common/config/VivadoHls_boards.xml`.

Command `create` creates Makefile and tcl scripts.
Option `-b` specifies board name, and last string `adder` specifies project name.

```
$ vivado_hls_create_project create -b Zybo_Z7_20 adder
[I 190623 20:21:41 generator:45] generate adder
[I 190623 20:21:41 generator:45] generate adder/include
[I 190623 20:21:41 generator:45] generate adder/src
[I 190623 20:21:41 generator:45] generate adder/test/include
[I 190623 20:21:41 generator:45] generate adder/test/src
[I 190623 20:21:41 generator:45] generate adder/script
[I 190623 20:21:41 generator:49] generate Makefile
[I 190623 20:21:41 generator:64] generate tcl scripts
[I 190623 20:21:41 deviceinfo:35] Part of Zybo_Z7_20 found -> xc7z020clg400-1
[I 190623 20:21:41 generator:111] generate directives.tcl
[I 190623 20:21:41 generator:116] generate .gitignore
$ tree adder
adder
├── Makefile
├── directives.tcl
├── include
├── script
│   ├── cosim.tcl
│   ├── csim.tcl
│   ├── csynth.tcl
│   ├── export.tcl
│   └── init.tcl
├── src
└── test
    ├── include
    └── src

6 directories, 7 files
```

include/ is a directory for header and src/ is for C++ files.
test/ is for test codes.

# C simulation

Write source code of adder module.

- include/adder.hpp

```
#ifndef _ADDER_HPP_
#define _ADDER_HPP_

void adder(int a, int b, int *sum);

#endif // _ADDER_HPP_
```

- src/adder.cpp

```
#include "adder.hpp"

void adder(int a, int b, int *sum) {
    *sum = a + b;
}
```

Also write test bench .

- test/src/test_adder.cpp

```
#include "adder.hpp"

#include <cassert>

int main(int argc, const char **argv) {
    int a, b, sum;
    a = 10;
    b = 24;

    adder(a, b, &sum);
    assert(sum == (a + b));
    
    return 0;
}
```

C simulation is executed by using `make csim`.

# Building IP

If test is passed, build adder.
IP is exported by using `make export`.
Check the IP on Vivado!

![Adder IP]({{site.baseurl}}/assets/2019-06-23-vivado_hls_create_project/ip.png "Adder IP")

# Version management using git

There is a .gitignore in the project.
It ignores a product.
So you can manage source codes, Makefile and tcl scripts with git. 

```
$ git init
Initialized empty Git repository in /xxx/xxx/adder/.git/
$ git status
On branch master

No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)

        .gitignore
        Makefile
        directives.tcl
        include/
        script/
        src/
        test/

nothing added to commit but untracked files present (use "git add" to track)
```

# Conclusion

If you find out bugs or problems, send me a message to [my twitter](https://twitter.com/isKenta14).

