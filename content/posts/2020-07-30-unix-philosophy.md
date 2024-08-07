---
title: UNIXという考え方 を読んだ
date: 2020-07-30 23:00:00 +0900
tags: [技術書]
toc: true
---

## 書籍情報

- 著者: Mike Gancarz
- 訳者: 芳尾 桂
- 書籍名: UNIXという考え方
- 出版社: オーム社

## はじめに

　UNIX哲学を解説した、歴史的に最も有名な書籍であるところの**UNIXという考え方**だが、恥ずかしながら一度も読んだことが無かった。
Amazonで別の書籍を注文するついでに購入した。
長らくLinux環境で開発をしていたのでUNIX的な考え方を理解したつもりであったが、先人達の言葉でこの思想を再認識したかった。

　**UNIXという考え方**は、UNIXと関連するプログラムの設計思想、そして使いこなし方を説いてくれた。
UNIXの誕生から50余年を経ても、哲学のピースの多くは色褪せていない。

　特に共感できたピースである定理2, 3, 8をご紹介したい。

## 定理2: 一つのプログラムには一つのことをうまくやらせる

　独自のプログラムを作っているときに、つい幾つものユーティリティを内蔵させる体験は多くの人が経験しているはずだ。
一つより多くのことをプログラムにさせようとすれば、そのプログラムは保守しづらく、ごく少数のユーザにしか支持されなくなってしまう。

　UNIX哲学では、小さなプログラムこそが美であると説いている。
もし手の込んだコトをしたければ、標準入出力とパイプを活用して複数のプログラムを連携させればいい。

---

　私は定理2に従わなかったプロダクトによって日常生活で苦しめられている。
数年前に母が買ってきたDVDレコーダのリモコンだ。

　リモコンはそれだけでテレビ番組の録画、DVDの再生、チャンネルの変更、番組表の切り替え、入力の切り替え、その他諸々ができる。
母は器用に操作して数百時間分の番組を録画し、視聴している。

　しかしただでさえテレビを見ない私は、たまにNHKを視ようとすると、数分はリモコンと格闘する羽目になる。
一つのリモコンに、DVDレコーダが扱う機能の全てが操作できるように設計されていたからだ。
しかもこのリモコンは少し変わっていて、あるボタンを押すと全てのボタンの機能が一時的に切り替わる恐ろしい代物だ。
(Vimmerの私は、この変わったキーをEscapeキーと呼んでいる)

## 定理3: できるだけ早く試作する

　プログラマが犯しがちな事の一つに、目的を忘れてつい大風呂敷を広げて"至れり尽せりな"プログラムを開発することがある。
「あれができたら、これができたら」と設計の段階で余計な機能まで入れてしまうと、最後は誰も保守せず使わずなジャンクが生まれてしまう。
定理2でも触れられていたように、あくまで"一つのことをうまくやる"プログラムを作ったほうがUNIX的には生産的だ。
月を探索するために戦艦ヤマトやデス・スターを建造する必要は無い。

　シンプルなプログラムを開発することが生産的なのは、ユーザからのフィードバックを反映させるチャンスが多いことも要因だ。
シンプルさはプログラムのリリースを早め、ユーザにプログラムへの理解を促し、開発者にプログラムを修正しやすくさせる。
もし問題のある機能を搭載してしまったとしても、シンプルなプログラムなら修正してすぐにリリースすることができる。

　この考えは現代的なソフトウェア開発プロセスによく似ている。
プロトタイプを作り、ユーザからのフィードバックを反映させ、開発と修正を反復し続けるのはアジャイル開発にも通じている。
いきなり完璧なソフトウェアを目指すのではなく、ソフトウェアを成長させていく考え方は[先日読んだソフトウェア・ファースト](https://kenta11.github.io/2020/07/27/software-first-jp/)でも言及されていた。
近頃広く受け入れられた思想が、数十年以上前に萌芽していたことは驚きである。

## 定理8: 過度の対話的インタフェースを避ける

　対話的インタフェースは、プログラムの操作を逐一ユーザに尋ねるインタフェースだ。
GUIはまさに対話的インタフェースの具体例である。
Amazonで欲しい商品があれば、ユーザは「カートに入れる」ボタンでカートに入れる。
購入を決めると、Amazonは適宜カード番号や住所を訪ねてくる。
これはまさにプログラムとユーザの対話だ。

　対話的インタフェースは多くの人々にフレンドリーなものの、コンピュータに対しては非フレンドリーである。
対話的インタフェースは必要なデータや次に実行する処理を逐一訪ねてくる。
この性質は他のプログラムとの連携を著しく困難にする。

　またこれは私の考えだが、対話的インタフェースはプログラムの性能をユーザに律速させてしまう。
UNIXは複数のプログラムをパイプで連携して、高度な処理を効率的に実現する。
しかし対話的インタフェースは車のハンドルのようなもので、常にプログラムの面倒をみてやらなければならなくなる。
対話的インタフェースはUNIXの強みを封じてしまうわけだ。

## おわりに

　**UNIXという考え方**に登場する思想は現代でもその多くが色褪せておらず、非常に有益だった。
今なお生き続けるUNIX、そして子孫的存在のLinuxに根付く"UNIX哲学"は、現代のプログラム開発にも大いに参考にできる。
効率を重んじ、コンピュータの力を最大限に活用する哲学を身に着けて実践していきたい。
