---
layout: postjp
title: "UbuntuにVim環境を用意する"
description: "Vimをビルドしてインストールする手順"
date: 2019-01-14 20:00:00 +0900
lang: jp
nav: post
category: 開発環境
tags: [Vim]
---

# まえがき

いろんなマシンでVimをビルドすることがあるので，その手順をメモ．

# Vimをビルド

GithubからVimをダウンロードする．

```
$ git clone https://github.com/vim/vim
```

ビルドの設定をしてからビルドする．

```
$ make distclean # すでにビルドをしたことがある場合は実行しておく
$ ./configure --with-features=huge \
            --disable-darwin \
            --disable-selinux \
            --enable-fail-if-missing \
            --enable-python3interp=dynamic \
            --enable-cscope \
            --enable-fontset \
            --with-compiledby=kenta \
            --enable-gui=no \
            --prefix=/usr/local

$ make -j8 # マシンのスペックによって値は変える
```

# Vimをインストール

Ubuntuの場合，checkinstallを使うことでVimをaptで管理できる．
make installせずにこちらを使う．

```
$ apt install checkinstall
$ checkinstall
# インストールするパッケージが更新されないように，holdをかけておく
$ echo "vim hold"         | dpkg --set-selections
$ echo "vim-common hold"  | dpkg --set-selections
$ echo "vim-runtime hold" | dpkg --set-selections
$ echo "vim-tiny hold"    | dpkg --set-selections
```

# Plugin

Vimのプラグインを準備する．私のVim用設定ファイルはGithub上に置いてあるので，これを使う．

```
$ git clone https://github.com/Kenta11/dotfiles ; cd dotfiles
$ bash install.sh
```

これでホームに.vimと.vimrcのシンボリックリンクができる．vimを実行すればプラグインがインストールされる．

# もしuninstallする場合は

以下のコマンドを実行する．

```
$ echo "vim install"         | dpkg --set-selections
$ echo "vim-common install"  | dpkg --set-selections
$ echo "vim-runtime install" | dpkg --set-selections
$ echo "vim-tiny install"    | dpkg --set-selections

$ apt remove --purge vim
```

