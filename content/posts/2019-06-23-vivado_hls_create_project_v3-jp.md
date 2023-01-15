---
title: vivado_hls_create_project ver.3.0.0へのアップデート
date: 2019-06-23 20:00:00 +0900
tags: [Vivado HLS, make]
toc: true
---

vivado_hls_create_projectを大改修しました．変更点は以下の通りです．

- pipでインストールできるように
- settings.\*の廃止
- オプション名

またリファクタリングを行い，バグの修正しました．
修正したバグは以下の通りです．

- compiler_arg, linker_argで先頭がハイフンの引数を渡した場合にプロジェクトが作成されない

## pipでのインストール

vivado_hls_create_projectはpipでインストールできるようになりました．

```
$ git clone https://github.com/Kenta11/vivado_hls_create_project
$ sudo pip install vivado_hls_create_project
$ vivado_hls_create_project -h
Usage: vivado_hls_create_project [-h|--help] <command> [<args>]

Makefile and tcl scripts generator for Vivado HLS

<command>:
    list         list usable boards
    create       create Makefile and tcl scripts

optional arguments:
  -h, --help     show this help message and exit
```

## settings.\*の廃止

settings.\*を廃止しました．.bashrc等に書いたsourceコマンドは削除することを推奨します．

## オプション名

`vivado_hls_create_project create`のオプション名を一部変更しました．変更されたのは以下の2つです．

- compiler_arg -> compiler_argument
- linker_arg -> linker_argument
