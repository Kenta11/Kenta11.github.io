---
title: 情報工学実験II（再々履修）
date: 2023-03-18 19:00:00 +09:00
tags: [MICRO-1, SystemVerilog]
toc: true
---

## はじめに

MICRO-1 の FPGA 実装をしました．
最近 SystemVerilog を書き始めたことと，HDL 開発におけるテスト手法を調べたことで，何か成果を作りたくなったためです．

## 成果

- [MICRO-alpha](https://github.com/Kenta11/micro-alpha)

## MICRO-1 との相違点

MICRO-alpha は MICRO-1 で実行できる制御命令を全てサポートしたのですが，実際に実装するにあたって，設計の細かな部分を変更しました．

機械語の入出力命令はカードリーダとラインプリンタを扱うのですが，流石にそんなものは身の回りにありません．
そこで UART を使ったシリアル通信で代用しました．

入力命令は R0 レジスタにシリアル入力を書き込むように変更しました．
ただし入力が無い場合が想定されるので，その場合は R0 をゼロクリアします．
入力がないケースは少なくともテキストでは想定されていないので，やむを得ずこのような対処をしています．

出力命令は R0 レジスタをシリアル出力するように変更しました．

テキストでは，主記憶装置が「比較的大容量の記憶装置である」と書かれていますが，MICRO-1 の主記憶装置は現代の感覚ではかなり小さい（16bit x 64K）です．
なので FPGA 実装では Block RAM を主記憶装置に充てました．

また細かいところですが，制御装置の動作周波数はテキストの 20MHz ではなく 100MHz としました．
これは実装した FPGA ボードのクロック入力と同じ動作周波数にしています．

## 遊び方

**（追記）v1.1.4 から CLI 上で Vivado プロジェクトを作成できるようにしました． v1.1.4 で遊ぶ場合は「Vivado プロジェクトを作成（v1.1.4 以降）」を参照してください．**

### Vivado プロジェクトを作成（v1.1.4 以前）

[以前の記事](../2022-09-23-micro1)で紹介したツールをインストールしたマシンで回路合成します．
[MICRO-alpha](https://github.com/Kenta11/micro-alpha)のリポジトリをクローンして，そのディレクトリ内にて[リリースのページ](https://github.com/Kenta11/micro-alpha/releases/tag/v1.0.0)で公開している Vivado プロジェクト (micro-alpha-arty-a7-100.tar.gz) を解凍します．

```shell
$ git clone https://github.com/Kenta11/micro-alpha
$ cd micro-alpha
$ wget https://github.com/Kenta11/micro-alpha/releases/download/v1.0.0/micro-alpha-arty-a7-100.tar.gz
$ tar zxvf micro-alpha-arty-a7-100.tar.gz
$ tree -L 1
.
├── LICENSE
├── Makefile
├── README.md
├── micro-alpha-arty-a7-100.tar.gz
├── run.py
├── micro-alpha
├── script
├── src
├── tb
```

マイクロプログラムを制御記憶に書き込むための COE ファイルを作成します．

```shell
$ curl -s http://www.ced.is.utsunomiya-u.ac.jp/lecture/2022/jikkenb/micro/chap5/MICROONE | iconv -f sjis -t utf8 | tr -d "\32" > MICROONE
$ rm1masm MICROONE -o MICROONE.o
$ python script/obj2coe.py MICROONE.o micro-alpha/micro-alpha.srcs/sources_1/ip/control_memory/control_program.coe
```

続いて機械語プログラムを制御記憶に書き込むための COE ファイルを作成します．

```shell
$ cat calculator 
; This program is distributed under MIT LICENSE.
; Copyright (c) 2023 Kenta Arai

; 逆ポーランド記法電卓プログラム
; 
; 実行例（(3+4)*(4-2)）
; (CALCULATOR)>> 3 4 + 4 2 - *
; 14
TITLE CALCULATOR
             ORG  140
CALCULATOR0: LA   1, PROMPT
             BSR  PRINT
             LA   1, INPUT
             BSR  RWLINE
             LA   0, INPUT
             BSR  INTERPRET
             BSR  PUTINT
             B    CALCULATOR0
             HLT

; データ領域
PROMPT:      DC   ' (
             DC   ' c
             DC   ' a
             DC   ' l
             DC   ' c
             DC   ' )
             DC   ' >
             DC   ' >
             DC   '  
             DC   0
INPUT:       DS   32

; 文字列を出力装置に書き込む関数
; 入力: {r1: 文字列の先頭アドレス}
; 出力: なし
PRINT0:      WIO  LPT
             LEA  1, 1(1)
PRINT:       LX   0, (1)
             OR   0, (0)
             BNZ  PRINT0
             RET

; 入力装置から行を読む関数
; 入力: {r1: 行の書込み先アドレス}
; 出力: なし
; NOTE: 読んだ文字は都度出力装置に書き込む
RWLINE0:     STX  0, (1)
             LEA  1, 1(1)
RWLINE:      BSR  READWORD
             WIO  LPT
             LC   2, X"0D
             CMP  0, (2)
             BNZ  RWLINE0
             WIO  LPT
             LC   0, X"0A
             WIO  LPT
             LC   0, 0
             STX  0, (1)
             RET

; 入力式を計算する
; 入力: {r0: 入力文字列}
; 出力: {r1: 計算結果}
INTERPRET:   LX   1, (0)
             CMP  1, 0       ; NULL
             BZ   INTERPRET5
             CMP  1, X"20    ; SP
             BZ   INTERPRET4
             CMP  1, X"2B    ; +
             BNZ  INTERPRET0
             POP  3, 2
             ADD  2, (3)
             PUSH 2, 1
             B    INTERPRET4
INTERPRET0:  CMP  1, X"2D    ; -
             BNZ  INTERPRET1
             POP  3, 2
             SUB  2, (3)
             PUSH 2, 1
             B    INTERPRET4
INTERPRET1:  CMP  1, X"2A    ; *
             BNZ  INTERPRET2
             POP  3, 1
             POP  1, 1
             MULT 1, (3)
             PUSH 2, 1
             B    INTERPRET4
INTERPRET2:  CMP  1, X"2F    ; /
             BNZ  INTERPRET3
             POP  3, 2
             LC   1, 0
             DIV  1, (3)
             PUSH 2, 1
             B    INTERPRET4
INTERPRET3:  BSR  ISDIGIT    ; '0'-'9'
             CMP  1, 0
             BZ   INTERPRET6
             BSR  ATOI
             PUSH 1, 1
INTERPRET4:  ADD  0, 1
             B    INTERPRET
INTERPRET5:  POP  1, 1
INTERPRET6:  RET

; 整数を出力装置に書き込む関数
; 入力: {r1: 数値}
; 出力: なし
PUTINT:      LC   0, X"30
             WIO  LPT
             LC   0, X"78
             WIO  LPT
             LEA  2, (1)    ; r1[15:12] を出���
             SC   2, 4
             AND  2, X"F
             LA   3, DIGIT
             ADD  2, (3)
             LX   0, (2)
             WIO  LPT
             LEA  2, (1)    ; r1[11:8] を出力
             SC   2, 8
             AND  2, X"F
             LA   3, DIGIT
             ADD  2, (3)
             LX   0, (2)
             WIO  LPT
             LEA  2, (1)    ; r1[7:4] を出力
             SC   2, 12
             AND  2, X"F
             LA   3, DIGIT
             ADD  2, (3)
             LX   0, (2)
             WIO  LPT
             LEA  2, (1)    ; r1[3:0] を出力
             AND  2, X"F
             LA   3, DIGIT
             ADD  2, (3)
             LX   0, (2)
             WIO  LPT
             LC   0, X"0D
             WIO  LPT
             LC   0, X"0A
             WIO  LPT
             RET
DIGIT:       DC   X"30
             DC   X"31
             DC   X"32
             DC   X"33
             DC   X"34
             DC   X"35
             DC   X"36
             DC   X"37
             DC   X"38
             DC   X"39
             DC   X"41
             DC   X"42
             DC   X"43
             DC   X"44
             DC   X"45
             DC   X"46

; 入力装置から文字を読む関数
; 入力: なし
; 出力: {r0: 読んだ文字}
; NOTE: MICRO-alpha は入力が無い場合にヌル文字を読んだ扱いとする
;       この関数はヌル文字以外を読むまで，入力装置から文字を読み続ける
READWORD:    RIO  CR
             OR   0, (0)
             BZ   READWORD
             RET

; 入力文字列を数値に変換する
; 入力: {r0: 入力文字列}
; 出力: {r0: 入力文字列(読み進めたアドレス), r1: 変換後の数値}
ATOI:        LC   1, 0
ATOI0:       PUSH 1, 1
             LX   1, (0)
             BSR  ISDIGIT
             CMP  1, 0
             POP  1, 1
             BNZ  ATOI1
             RET
ATOI1:       MULT 1, 10
             LX   1, (0)
             SUB  1, X"30
             ADD  1, (2)
             ADD  0, 1
             B    ATOI0

; 入力文字が数字('0'-'9')であるかを判定する
; 入力: {r1: 入力文字}
; 出力: {r1: 判定結果(1: 数字である，0: 数字でない)}
ISDIGIT:     CMP  1, X"30
             BM   ISDIGIT0
             CMP  1, X"39
             BP   ISDIGIT0
             LC   1, 1
             RET
ISDIGIT0:    LC   1, 0
             RET
END
$ rm1asm calculator -o calculator.b
$ python script/obj2coe.py calculator.b micro-alpha/micro-alpha.srcs/sources_1/ip/main_memory/machine_program.coe
```

### Vivado プロジェクトを作成（v1.1.4 以降）

- **注意：Basys 3 で動かす場合は以下のように読み替えてください**
  - `fpga/arty-a7-100/` -> `fpga/basys-3/`
  - Makefile の変数 `SCRIPT` を Basys3 用に切り替える

[以前の記事](../2022-09-23-micro1)で紹介したツールをインストールしたマシンで回路合成します．
[MICRO-alpha](https://github.com/Kenta11/micro-alpha)のリポジトリをクローンしてください．

```shell
$ git clone https://github.com/Kenta11/micro-alpha
$ cd micro-alpha
$ tree -L 1
.
├── LICENSE
├── Makefile
├── README.md
├── fpga
├── script
├── src
└── tb

5 directories, 3 files
```

マイクロプログラムを制御記憶に書き込むための COE ファイルを作成します．

```shell
$ curl -s http://www.ced.is.utsunomiya-u.ac.jp/lecture/2022/jikkenb/micro/chap5/MICROONE | iconv -f sjis -t utf8 | tr -d "\32" > MICROONE
$ rm1masm MICROONE -o MICROONE.o
$ python script/obj2coe.py arty-a7-100 MICROONE.o fpga/arty-a7-100/control_program.coe
```

続いて，機械語プログラムを主記憶に書き込むための COE ファイルを作成します．

```shell
$ cat calculator 
; This program is distributed under MIT LICENSE.
; Copyright (c) 2023 Kenta Arai

; 逆ポーランド記法電卓プログラム
; 
; 実行例（(3+4)*(4-2)）
; (CALCULATOR)>> 3 4 + 4 2 - *
; 14
TITLE CALCULATOR
             ORG  140
CALCULATOR0: LA   1, PROMPT
             BSR  PRINT
             LA   1, INPUT
             BSR  RWLINE
             LA   0, INPUT
             BSR  INTERPRET
             BSR  PUTINT
             B    CALCULATOR0
             HLT

; データ領域
PROMPT:      DC   ' (
             DC   ' c
             DC   ' a
             DC   ' l
             DC   ' c
             DC   ' )
             DC   ' >
             DC   ' >
             DC   '  
             DC   0
INPUT:       DS   32

; 文字列を出力装置に書き込む関数
; 入力: {r1: 文字列の先頭アドレス}
; 出力: なし
PRINT0:      WIO  LPT
             LEA  1, 1(1)
PRINT:       LX   0, (1)
             OR   0, (0)
             BNZ  PRINT0
             RET

; 入力装置から行を読む関数
; 入力: {r1: 行の書込み先アドレス}
; 出力: なし
; NOTE: 読んだ文字は都度出力装置に書き込む
RWLINE0:     STX  0, (1)
             LEA  1, 1(1)
RWLINE:      BSR  READWORD
             WIO  LPT
             LC   2, X"0D
             CMP  0, (2)
             BNZ  RWLINE0
             WIO  LPT
             LC   0, X"0A
             WIO  LPT
             LC   0, 0
             STX  0, (1)
             RET

; 入力式を計算する
; 入力: {r0: 入力文字列}
; 出力: {r1: 計算結果}
INTERPRET:   LX   1, (0)
             CMP  1, 0       ; NULL
             BZ   INTERPRET5
             CMP  1, X"20    ; SP
             BZ   INTERPRET4
             CMP  1, X"2B    ; +
             BNZ  INTERPRET0
             POP  3, 2
             ADD  2, (3)
             PUSH 2, 1
             B    INTERPRET4
INTERPRET0:  CMP  1, X"2D    ; -
             BNZ  INTERPRET1
             POP  3, 2
             SUB  2, (3)
             PUSH 2, 1
             B    INTERPRET4
INTERPRET1:  CMP  1, X"2A    ; *
             BNZ  INTERPRET2
             POP  3, 1
             POP  1, 1
             MULT 1, (3)
             PUSH 2, 1
             B    INTERPRET4
INTERPRET2:  CMP  1, X"2F    ; /
             BNZ  INTERPRET3
             POP  3, 2
             LC   1, 0
             DIV  1, (3)
             PUSH 2, 1
             B    INTERPRET4
INTERPRET3:  BSR  ISDIGIT    ; '0'-'9'
             CMP  1, 0
             BZ   INTERPRET6
             BSR  ATOI
             PUSH 1, 1
INTERPRET4:  ADD  0, 1
             B    INTERPRET
INTERPRET5:  POP  1, 1
INTERPRET6:  RET

; 整数を出力装置に書き込む関数
; 入力: {r1: 数値}
; 出力: なし
PUTINT:      LC   0, X"30
             WIO  LPT
             LC   0, X"78
             WIO  LPT
             LEA  2, (1)    ; r1[15:12] を出���
             SC   2, 4
             AND  2, X"F
             LA   3, DIGIT
             ADD  2, (3)
             LX   0, (2)
             WIO  LPT
             LEA  2, (1)    ; r1[11:8] を出力
             SC   2, 8
             AND  2, X"F
             LA   3, DIGIT
             ADD  2, (3)
             LX   0, (2)
             WIO  LPT
             LEA  2, (1)    ; r1[7:4] を出力
             SC   2, 12
             AND  2, X"F
             LA   3, DIGIT
             ADD  2, (3)
             LX   0, (2)
             WIO  LPT
             LEA  2, (1)    ; r1[3:0] を出力
             AND  2, X"F
             LA   3, DIGIT
             ADD  2, (3)
             LX   0, (2)
             WIO  LPT
             LC   0, X"0D
             WIO  LPT
             LC   0, X"0A
             WIO  LPT
             RET
DIGIT:       DC   X"30
             DC   X"31
             DC   X"32
             DC   X"33
             DC   X"34
             DC   X"35
             DC   X"36
             DC   X"37
             DC   X"38
             DC   X"39
             DC   X"41
             DC   X"42
             DC   X"43
             DC   X"44
             DC   X"45
             DC   X"46

; 入力装置から文字を読む関数
; 入力: なし
; 出力: {r0: 読んだ文字}
; NOTE: MICRO-alpha は入力が無い場合にヌル文字を読んだ扱いとする
;       この関数はヌル文字以外を読むまで，入力装置から文字を読み続ける
READWORD:    RIO  CR
             OR   0, (0)
             BZ   READWORD
             RET

; 入力文字列を数値に変換する
; 入力: {r0: 入力文字列}
; 出力: {r0: 入力文字列(読み進めたアドレス), r1: 変換後の数値}
ATOI:        LC   1, 0
ATOI0:       PUSH 1, 1
             LX   1, (0)
             BSR  ISDIGIT
             CMP  1, 0
             POP  1, 1
             BNZ  ATOI1
             RET
ATOI1:       MULT 1, 10
             LX   1, (0)
             SUB  1, X"30
             ADD  1, (2)
             ADD  0, 1
             B    ATOI0

; 入力文字が数字('0'-'9')であるかを判定する
; 入力: {r1: 入力文字}
; 出力: {r1: 判定結果(1: 数字である，0: 数字でない)}
ISDIGIT:     CMP  1, X"30
             BM   ISDIGIT0
             CMP  1, X"39
             BP   ISDIGIT0
             LC   1, 1
             RET
ISDIGIT0:    LC   1, 0
             RET
END
$ rm1asm calculator -o calculator.b
$ python script/obj2coe.py arty-a7-100 calculator.b fpga/arty-a7-100/machine_program.coe
```

make コマンドを実行すると，Vivado のプロジェクトが作成されます．

```shell
$ make all
$ tree -L 2 vivado
vivado
└── arty-a7-100
    ├── arty-a7-100.cache
    ├── arty-a7-100.gen
    ├── arty-a7-100.hw
    ├── arty-a7-100.ip_user_files
    ├── arty-a7-100.srcs
    └── arty-a7-100.xpr

7 directories, 1 file
```

### FPGA 上で逆ポーランド記法プログラムを動作させる

Vivado で回路を合成し，Arty A7-100 に書き込みましょう．
シリアル通信で Arty A7-100 にキーボード入力をしましょう．

```shell
$ sudo screen /dev/ttyUSB1 115200
(calc)>> 3 4 + 4 2 - *
0x000E
(calc)>> 
```

逆ポーランド記法の電卓で計算ができました！

## おわりに

今年度は MICRO-1 で散々遊びました．
もう遊びたくないですね．

何の役に立つのか分からない実装ですが，誰かしらに貢献できたら良いですね．
コンピュータ・アーキテクチャの歴史を学ぶ上で少しは参考になるのではないでしょうか．
なるのか？
ならなそう．
