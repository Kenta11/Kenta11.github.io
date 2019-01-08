---
layout: postjp
title: "Windows PCにManajaro Linuxをデュアルブートする"
description: "デュアルブートの手順をメモ"
date: 2019-01-08 23:00:00 +0900
lang: jp
nav: post
category: 開発
tags: [Manjaro Linux]
---

# 前書き

新しいノートPCを購入した．
SSDの容量が大きかったので，Linuxをデュアルブートしたいと思う．
ディストリビューションはManajro Linuxを選択した．

Manjaro LinuxはArch Linuxにデスクトップ環境を追加したもので，[ディストロウォッチのヒットランキング](https://distrowatch.com/dwres.php?resource=popularity)では最近一年で一位の人気のようだ．
Manajro Linuxを選んだ理由は3つある．

- リリースモデルがローリング・リリースである
    - リポジトリ上のソフトウェアが常に最新
- パッケージマネージャであるpacmanの使用感がシンプル
    - apt，dpkgやyumよりも使いやすくて好き
- Arch Linuxが標準で持たないデスクトップ環境が備わっている

# Manjaro Linuxをインストールする

インストールの手順はArch Wikiを参照しながら行った．

## ISOイメージを用意する

まずは[公式のホームページ](https://manjaro.org/download/)からISOイメージをダウンロードする．
XFCEやGNOMEなどデスクトップ環境の異なるエディションがあるので，好きなものを選ぶ．
私はi3エディションを選択した．

ダウンロードが終わったら，[Rufus](https://rufus.ie/)を使ってUSBメモリにISOイメージを焼く．
書込みの際にDDモードで書き込むかを尋ねられるので，DDモードを選択する．

これでインストールメディアが完成した．

## SSDをデュアルブートが出来るように設定する

購入したマシンのSSDはWindowsによって暗号化がされていた．
このままUEFIの設定を変更するとWindows10がブートできなくなるので，まず暗号化を無効にする．
まずWindowsのアイコンを右クリックし，設定を開く．
『更新とセキュリティ』をクリックし，『デバイスの暗号化』にある『オフにする』を選択する．
暫く待つと，暗号化が解除された．

次にSSDにLinuxをインストールする領域を確保する．
Windowsのアイコンを右クリックし,『ディスクの管理』を選択する．
Cドライブを右クリックし，『ボリュームの縮小』を選択する．
私はSSDをWindows10とLinux用で半分ずつに分けた．

続いてUEFIの設定を変更する．
このときインストールメディアのUSBメモリを接続しておく．
同じくWindowsの設定ウィンドウで『更新とセキュリティ』をクリックし，『回復』の『今すぐ再起動』をクリックする．
すると再起動にUEFIを起動するか聞かれるので，するを選ぶ．
UEFIが起動したら，高速スタートアップの設定，ファストブート，セキュアブートを解除する．
そしてUSBメモリのBoot Priorityを一番にし，その後OSを起動する．

## インストール

USBメモリのManajro Linuxが起動したら，OSのインストーラを実行してSSDの空き領域にインストールする．
インストーラの使い方はManjaro Wikiを参照すると良い(https://wiki.manjaro.org/index.php/Install_Desktop_Environments)．

# 環境設定

## 日本語入力

日本語入力が出来なかったので，そのためのパッケージをインストール

参考：[Japanese input with i3 and Arch/Manjaro](https://confluence.jaytaala.com/pages/viewpage.action?pageId=18579517)

```
sudo pacman -S fcitx-im fcitx-configtool fcitx-mozc yay
yay -S ttf-vlgothic\

echo "# Japanese input\
export QT_IM_MODULE=fcitx\
export XMODIFIERS=@im=fcitx\
export GTK_IM_MODULE=fcitx" >> ~/.profile

echo "exec --no-startup-id fcitx -d" >> ~/.config/i3/config
```

## ディレクトリ名

OSをインストールした際にリージョンをJapanとしたところ，ホームにあるディレクトリ名が日本語になってしまった．
以下のコマンドで英語に書き換える．

```
LANG=C xdg-user-dirs-update --force
```

日本語名のディレクトリは残ってしまったので自分で消した．

## 時計

Manajro Linuxでは9時間前の時刻が表示された．
これはWindowsとハードウェアクロックを共有していることが原因だそうだ(参考：https://wiki.archlinux.org/index.php/System_time#Time_standard)．
LinuxとWindowsの双方で正しい時刻が表示されるように設定する．

### Linux

ntpdを有効にして，ハードウェアクロックをUTCで同期する．

参考
- [VAIO Z で Arch LinuxとWindows 10をデュアルブートする](https://qiita.com/mopp/items/f1912433abbed69f5f99#%E6%99%82%E5%88%BB%E3%81%AE%E8%A8%AD%E5%AE%9A)
- [ArchWiki 時刻](https://wiki.archlinux.jp/index.php/%E6%99%82%E5%88%BB#Windows_.E3.81.A7_UTC_.E3.82.92.E4.BD.BF.E3.81.86)

```
pacman -S ntp
timedatectl set-local-rtc false
ntpd -gq
hwclock --systohc
systemctl enable ntpd.service
```

### Windows

WindowsにハードウェアクロックをUTCとして使わせる．
Win+rでregeditを起動し，以下のレジストリに16進数で1のDWORD値を設定する．

```
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation\RealTimeIsUniversal
```

# 後書き

Manjaro LinuxとWindowsを両方使える環境が出来た．
PowerPointのスライドやWindowsでしか使えないアプリはWindows10で，開発やレポートはManjaro Linuxでやろうと思っている．

