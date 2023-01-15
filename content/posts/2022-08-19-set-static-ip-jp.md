---
title: Manjaroで静的IPアドレスを設定
date: 2022-08-19 23:45:00 +0900
tags: [Manjaro Linux]
toc: true
---
## はじめに

静的IPアドレスを設定するだけでも記事が色々あり，どれを信用したらいいか全く分からなかった．
netplanであったり，systemd-networkdであったり，NetworkManagerであったり，どれを使えば良いんじゃい，という具合である．
備忘録として，実施した手順を記録しておく．

## 上手くいかなかったケース：systemd-networkdを使う方法

[ArchWiki](https://wiki.archlinux.jp/index.php/Systemd-networkd#.E6.9C.89.E7.B7.9A.E3.82.A2.E3.83.80.E3.83.97.E3.82.BF.E3.81.A7.E5.9B.BA.E5.AE.9A_IP_.E3.82.92.E4.BD.BF.E7.94.A8)にもあるように，`/etc/systemd/network`下に設定ファイルを記述し，`systemd-networkd`を再起動する．
これで静的IPアドレスを設定できるのだが，なんとDHCPクライアントが動きっぱなしであるため，IPアドレスを2つ持ってしまう．
2つ持つなんてホントにできるのか分かっていないのだが，`ip`コマンドで2つのIPアドレス（静的に設定したものとDHCPサーバから取得したもの）を確認できる．

## 上手くいくケース：nmcliを使う方法

NetworkManagerもネットワーク設定のためのツールであるが，こちらではDHCPクライアントを停止させる方法があった．
nmcliを使って簡単に設定をすることができる．

以下の例では，インターフェースensに静的IPアドレスを設定する例を示す．

```
$ sudo nmcli c down ens # インターフェースを無効化
$ sudo nmcli c modify ens ipv4.addresses XXX.XXX.XXX.XXX/XX # IPアドレスXXX.XXX.XXX.XXX，サブネットマスクXXを設定
$ sudo nmcli c modify ens ipv4.gateway XXX.XXX.XXX.XXX # デフォルトゲートウェイのIPアドレスを設定
$ sudo nmcli c modify ens ipv4.method manual # IPアドレスを静的に設定（これでDHCPサーバからIPアドレスを取得しなくなる）
$ sudo nmcli c up ens # インターフェースを有効化
$ 
$ sudo systemctl restart NetworkManager # NetworkManagerを再起動
```

以上の手順で，静的に設定したIPアドレスのみを使用するようになる．

