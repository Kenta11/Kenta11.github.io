---
title: Vitis HLS on Ubuntu on Manjaro
date: 2023-04-28 21:30:00 +09:00
tags: [Vitis HLS, Manjaro, Docker]
toc: true
---

## はじめに

Manjaro で Vitis HLS の[サンプルプログラム](https://github.com/Kenta11/Vitis-HLS-Introductory-Examples)を試したところ，CSIM ができなかった．
サポートされていない Manjaro で試行錯誤するのも時間の浪費なので，Docker で Ubuntu コンテナを動かし，そこで Vitis HLS を試してみることにする．

## 前提条件

- Vitis HLS をインストールしたマシン上で Docker を動作させる
  - Ubuntu コンテナのファイルシステムで Vitis のディレクトリをマウントし，Vitis をインストールした Ubuntu 環境を擬似的に用意する

## Docker 上で Ubuntu コンテナを動作させる

以下の Dockerfile を準備する．
`apt install` でいくつかパッケージをインストールする．
これらのパッケージは CSIM で必要になる．
また，環境変数`LIBRARY_PATH`を定義しているが，これも CSIM で必要になる．

```Dockerfile
FROM ubuntu:22.04
LABEL maintainer "Kenta Arai <>"

RUN apt update -y \
  && apt dist-upgrade -y \
  && apt autoremove -y \
  && apt install build-essential gcc-multilib git language-pack-en libc6-dev libtinfo5 -y \
  && echo "export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu" >> ~/.bashrc
```

次に Docker イメージを作成し，コンテナを生成する．
`/opt` 下に Vitis をインストールしたディレクトリをマウントする．

```shell
$ ls
Dockerfile
$ sudo docker buildx build -t ubuntu_22.04_for_vitis .
$ sudo docker run -it --name ubuntu_22.04_for_vitis \
--mount type=bind,src=/opt/Xilinx/2022.2,dst=/opt/Xilinx/2022.2,readonly \
ubuntu_22.04_for_vitis /bin/bash
```

## Ubuntu 上で Vitis HLS を動作させる

Vitis HLS のサンプルプログラムをダウンロードし，`vitis_hls`で論理合成，CSIM，COSIM を開始する．

```shell
# cd ~
# git clone https://github.com/Kenta11/Vitis-HLS-Introductory-Examples
# cd Vitis-HLS-Introductory-Examples/Modeling/using_vectors/
# source /opt/Xilinx/2022.2/Vivado/2022.2/settings64.sh
# vitis_hls -f run_hls.tcl
```

論理合成と CSIM を無事に完了することができた．
ただし COSIM は途中で終了してしまった．
以下は COSIM のログである．

```
****** xsim v2022.2 (64-bit)
  **** SW Build 3671981 on Fri Oct 14 04:59:54 MDT 2022
  **** IP Build 3669848 on Fri Oct 14 08:30:02 MDT 2022
    ** Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.

source xsim.dir/example/xsim_script.tcl
# xsim {example} -autoloadwcfg -tclbatch {example.tcl}
Time resolution is 1 ps
source example.tcl
## run all
////////////////////////////////////////////////////////////////////////////////////
// Inter-Transaction Progress: Completed Transaction / Total Transaction
// Intra-Transaction Progress: Measured Latency / Latency Estimation * 100%
//
// RTL Simulation : "Inter-Transaction Progress" ["Intra-Transaction Progress"] @ "Simulation Time"
////////////////////////////////////////////////////////////////////////////////////
// RTL Simulation : 0 / 1 [n/a] @ "128000"
// RTL Simulation : 1 / 1 [n/a] @ "2523000"
////////////////////////////////////////////////////////////////////////////////////
$finish called at time : 2552500 ps : File "/root/Vitis-HLS-Introductory-Examples/Modeling/using_vectors/proj_example/solution1/sim/verilog/example.autotb.v" Line 588
## quit
INFO: [Common 17-206] Exiting xsim at Fri Apr 28 12:31:04 2023...
ERROR: [COSIM 212-4] *** C/RTL co-simulation finished: FAIL ***
INFO: [COSIM 212-211] II is measurable only when transaction number is greater than 1 in RTL simulation. Otherwise, they will be marked as all NA. If user wants to calculate them, please make sure there are at least 2 transactions in RTL simulation.
INFO: [HLS 200-111] Finished Command cosim_design CPU user time: 52.13 seconds. CPU system time: 2.92 seconds. Elapsed time: 46.81 seconds; current allocated memory: 9.879 MB.
command 'ap_source' returned error code
    while executing
"source run_hls.tcl"
    ("uplevel" body line 1)
    invoked from within
"uplevel \#0 [list source $arg] "

INFO: [HLS 200-112] Total CPU user time: 71.46 seconds. Total CPU system time: 4.64 seconds. Total elapsed time: 78.79 seconds; peak allocated memory: 912.445 MB.
INFO: [Common 17-206] Exiting vitis_hls at Fri Apr 28 12:31:04 2023...
```

## おわりに

Vitis HLS の CSIM は Manjaro ではできなかったが，Docker 上で動作する Ubuntu コンテナでは CSIM をすることができた．
ただし COSIM はできなかった．
公式のサンプルプログラムなので COSIM ができないということは無いと思いたい．
余力があれば原因を調べよう．
