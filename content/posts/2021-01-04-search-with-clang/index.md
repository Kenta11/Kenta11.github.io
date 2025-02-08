---
title: Pythonでlibclangを使って関数呼び出しを探す
date: 2021-01-22 00:00:00 +0900
tags: [Python, Clang]
toc: true
---
## はじめに

ひょんなことからCプログラム中のある関数を呼び出している箇所を見つけようと思った。
しかし巨大なプロジェクト相手には骨が折れる。
ましてやマクロを介して関数を呼び出されていた場合には、手のつけようがない。

そこでプリプロセス済みのソースコードを一旦ASTにし、関数呼び出しをしている箇所を取り出せばいいと気付いた。
調べてみると、LLVMのASTをイジったり中身を見る方法があるようだ。

本稿ではPythonを使ってCソースコードの関数呼び出しを見つける。
LLVMをゴリゴリ使うLigToolingなるものもあるようだが大変そうなので、PythonのClangインターフェースを使うことにする。

## 開発環境

- CPU: x64
- OS: Manjaro XFCE

## Pythonを使って関数呼び出しを探す

### 準備

Pythonを使ってソースコードを解析するにあたり、PythonとClangの準備をする。

```bash
# Manjaroでは初めからPython3がインストール済みなので、Clangだけ準備する
$ sudo pacman -S clang llvm # clangだけでは今回のPythonプログラムが動かなかった...
```

clangモジュールが`/usr/lib/python3.9/site-packages/clang/`にあれば、準備完了だ。

### 関数呼び出しの箇所を探す

`parse()`を呼び出すと、よしなにASTにしてくれる。
どうやらプリプロセスまでしてくれるようだ。

```python
# -*- coding: utf-8 -*-

import sys
import clang.cindex

def visitNode(node, search_function_name, declared_function_name=None):
    if node.kind.name == 'FUNCTION_DECL':
        declared_function_name = node.spelling
    elif node.kind.name == 'CALL_EXPR':
        print(search_function_name, declared_function_name, node.location.line)

    for c in node.get_children():
        visitNode(c, search_function_name, declared_function_name)

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} FUNCTION_NAME FILE", file=sys.stderr)
        exit(1)

    index = clang.cindex.Index.create()
    tree = index.parse(sys.argv[2])
    visitNode(tree.cursor, sys.argv[1])
```

もしも特定の名前の型や変数名を検索したい場合は、`visitNode()`を改造すればできる。
なおASTのノードの種類については、clangモジュールに書かれていたコメントを参考に記述した。
（FUNCTION\_DECLは関数宣言な気もするが、どうも関数定義も含んでいるようだ。）

### vim\_snprintf()を探す

作成したPythonプログラムを使用して、関数呼び出しを探してみる。
今回はvimのソースコードをターゲットに、`vim_snprintf`を探す。

```
$ git clone https://github.com/vim/vim
$ python3 sample.py vim_snprintf vim/src/main.c
vim_snprintf main 106
vim_snprintf main 119
vim_snprintf main 153
vim_snprintf main 164
vim_snprintf main 185
vim_snprintf main 191
vim_snprintf main 230
# 長いので割愛
```

1列目に検索した関数名（もちろん`vim_snprintf`）、2列目に`vim_snprintf`を呼び出している関数名、3列目に行番号が標準出力されている。
無事に`vim_snprintf`を呼び出している場所を見つけられた。

## 読者プレゼント

お使いの環境で作業を試せる`Dockerfile`を置いておきます。
リンクは[こちら](Dockerfile)。

```Dockerfile
FROM ubuntu:20.04
LABEL maintainer "Kenta Arai <>"

COPY sample.py /sample.py

RUN apt update -y; apt dist-upgrade -y; apt autoremove -y && \
    apt install git python3 python-clang -y && \
    git clone https://github.com/vim/vim && \
    python3 sample.py vim_snprintf vim/src/main.c
```

## 参考文献

- [Clang の構文解析インターフェースを Python から叩いてみようという話](https://blog.fenrir-inc.com/jp/2011/07/clang_syntax_analysis_interface_with_python.html)
- [Clangのpython bindingsを使う](http://asdm.hatenablog.com/entry/2015/01/08/170707)
- [llvm-mirror/clang clang/bindings/python/clang/cindex.py](https://github.com/llvm-mirror/clang/blob/master/bindings/python/clang/cindex.py)
