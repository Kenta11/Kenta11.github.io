---
layout: postjp
title: manjaro linuxのミラーサーバを更新する
description: "ミラーサーバが使えなくなった場合に，参照先のサーバを自動で設定させる"
date: 2019-05-19 14:00:00 +0900
lang: jp
nav: post
category: 開発環境
tags: [Manjaro Linux]
---

# tukubaのミラーサーバが死んだ

pacmanでパッケージを更新しようとしたところ，以下のメッセージが表示された．

```
:: パッケージデータベースの同期中...
エラー: ファイル 'core.db' を ftp.tsukuba.wide.ad.jp から取得するのに失敗しました : The requested URL returned error: 403
エラー: core の更新に失敗しました (予期しないエラー)
エラー: ファイル 'extra.db' を ftp.tsukuba.wide.ad.jp から取得するのに失敗しました : The requested URL returned error: 403
エラー: extra の更新に失敗しました (予期しないエラー)
エラー: ファイル 'community.db' を ftp.tsukuba.wide.ad.jp から取得するのに失敗しました : The requested URL returned error: 403
エラー: community の更新に失敗しました (予期しないエラー)
エラー: ファイル 'multilib.db' を ftp.tsukuba.wide.ad.jp から取得するのに失敗しました : The requested URL returned error: 403
エラー: multilib の更新に失敗しました (予期しないエラー)
エラー: 全てのデータベースの同期に失敗しました
```

403が帰ってきたということはつまり，ftp.tukuba.wide.ad.jpにアクセスできないわけだ．
archlinuxのミラーサーバをチェックしにいくと，5月16日から接続不能になっていることがわかった．

[tukubaサーバのチェックログ](https://www.archlinux.jp/mirrors/ftp.tsukuba.wide.ad.jp/)．

# pacmanが参照するリポジトリを更新する

ミラーサーバの更新の仕方はmanjaro wikiに書かれていた．

[Pacman-mirrorsコマンドによるミラーサーバーリストの更新](https://wiki.manjaro.org/index.php?title=Pacman-mirrors%E3%82%B3%E3%83%9E%E3%83%B3%E3%83%89%E3%81%AB%E3%82%88%E3%82%8B%E3%83%9F%E3%83%A9%E3%83%BC%E3%82%B5%E3%83%BC%E3%83%90%E3%83%BC%E3%83%AA%E3%82%B9%E3%83%88%E3%81%AE%E6%9B%B4%E6%96%B0)．

```
$ sudo pacman-mirrors --fasttrack && sudo pacman -Syy
[sudo] kenta のパスワード:
::INFO Downloading mirrors from repo.manjaro.org
::INFO Using custom mirror file
::INFO Querying mirrors - This may take some time
  0.130 Japan          : http://ftp.riken.jp/Linux/manjaro/
  0.392 Japan          : ftp://ftp.riken.jp/Linux/manjaro/
::INFO Writing mirror list
::Japan           : http://ftp.riken.jp/Linux/manjaro/stable/$repo/$arch
::INFO Mirror list generated and saved to: /etc/pacman.d/mirrorlist
:: パッケージデータベースの同期中...
 core                                                                                   151.1 KiB  4.92M/s 00:00 [####################################################################] 100%
 extra                                                                                 1807.1 KiB  12.9M/s 00:00 [####################################################################] 100%
 community                                                                                5.2 MiB  2.43M/s 00:02 [####################################################################] 100%
 multilib                                                                               184.0 KiB  6.66M/s 00:00 [####################################################################] 100%
```

理研のミラーサーバを利用する設定に変更された．
