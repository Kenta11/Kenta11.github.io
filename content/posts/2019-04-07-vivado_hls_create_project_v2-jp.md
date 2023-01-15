---
title: vivado_hls_create_project(v2.0)へのアップデート
date: 2019-04-07 21:00:00 +0900
tags: [Vivado HLS, make]
toc: true
---

[vivado_hls_create_project](https://github.com/Kenta11/vivado_hls_create_project)にオプション機能を追加しすぎて使いづらくなったので，大幅な改修をしました．
破壊的更新をし，gitのようにサブコマンドで使う機能を選択できるようにしました．
といっても機能は`list`と`create`の2つだけです．
そしてプロジェクトのディレクトリをはじめから作るようにも変更しました．
簡単な使い方は[README](https://github.com/Kenta11/vivado_hls_create_project/README.md)を見ていただければ分かると思いますが，そちらで説明していないオプションをこっちで解説したいと思います．

`create`コマンドのヘルプを見ると，以下の内容が表示されます．

```
$ vivado_hls_create_project create --help
usage: vivado_hls_create_project create [-h] [-s SOLUTION] [-c CLOCK] [--template] [--compiler_arg COMPILER_ARG] [--linker_arg LINKER_ARG] -b BOARD project_name

positional arguments:
  project_name

optional arguments:
  -h, --help            show this help message and exit
  -s SOLUTION, --solution SOLUTION
                        Solution name
  -c CLOCK, --clock CLOCK                        Clock frequency of module
  --template            Option for C++ template source code generation
  --compiler_arg COMPILER_ARG
                        Arguments for compiler
  --linker_arg LINKER_ARG
                        Arguments for linker
  -b BOARD, --board BOARD
                        Board name
```

`-s`，`-c`はソリューションの設定に使用します．
`-s`はソリューション名を指定します．デフォルトではボード名と同じになります．
`-c`はモジュールのクロック周期を指定します．デフォルトでは100MHzです．`-c 125MHz`や`-c 2.0ns`というようにクロック周期を指定すると，tclスクリプトに反映されます．

`--template`はC++のソースコードを自動で生成するオプションです．
イチからプロジェクトを作る際に便利です．

Cシミュレーションに外部のライブラリを使う際は`--compiler_arg`と`--linker_arg`を使うことになると思います．
`--compiler_arg`はCシミュレーションのコンパイラ用の引数です．`src/`と`test/src`以下のコードをコンパイルする際に適用されます．
`--linker_arg`はCシミュレーションのリンク用の引数です．リンクの際に適用されます．

ZedBoard用にsampleというプロジェクトを作る場合は，以下のようにコマンドを実行して下さい．

```
$ vivado_hls_create_project create sample -b Xilinx_ZedBoard
INFO: Generating directory sample
INFO: Generating directory sample/include
INFO: Generating directory sample/src
INFO: Generating directory sample/test/include
INFO: Generating directory sample/test/src
INFO: Generating directory sample/script
INFO: Generating Makefile
INFO: Generating tcl scripts
INFO: Part of Xilinx_ZedBoard found -> xc7z020clg484-1
INFO: Generating directives.tcl
INFO: Generating .gitignore
$ tree sample
sample
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

`-b`はボード名を指定します．
使用可能なボード名は`list`コマンドで確認して下さい．

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

