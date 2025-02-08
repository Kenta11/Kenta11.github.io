---
title: UbuntuにVim環境を用意する
date: 2019-01-14 20:00:00 +0900
tags: [Vim]
toc: true
---

## まえがき

いろんなマシンでVimをビルドすることがあるので，その手順をメモ．

## Vimをビルド

GithubからVimをダウンロードする．

```shell
$ git clone https://github.com/vim/vim
```

ビルドの設定をしてからビルドする．

```shell
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

## Vimをインストール

Ubuntuの場合，checkinstallを使うことでVimをaptで管理できる．
make installせずにこちらを使う．

```shell
$ apt install checkinstall
$ checkinstall
# インストールするパッケージが更新されないように，holdをかけておく
$ echo "vim hold"         | dpkg --set-selections
$ echo "vim-common hold"  | dpkg --set-selections
$ echo "vim-runtime hold" | dpkg --set-selections
$ echo "vim-tiny hold"    | dpkg --set-selections
```

## Plugin

Vimのプラグインを準備する．私のVim用設定ファイルはGithub上に置いてあるので，これを使う．

```shell
$ git clone https://github.com/Kenta11/dotfiles ; cd dotfiles
$ bash install.sh
```

これでホームに.vimと.vimrcのシンボリックリンクができる．vimを実行すればプラグインがインストールされる．

## もしuninstallする場合は

以下のコマンドを実行する．

```shell
$ echo "vim install"         | dpkg --set-selections
$ echo "vim-common install"  | dpkg --set-selections
$ echo "vim-runtime install" | dpkg --set-selections
$ echo "vim-tiny install"    | dpkg --set-selections

$ apt remove --purge vim
```

