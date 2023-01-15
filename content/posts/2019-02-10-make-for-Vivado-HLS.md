---
title: makeコマンドでVivado HLSを使う
date: 2019-02-12 07:00:00 +0900
tags: [Vivado HLS, make]
toc: true
---

## はじめに

私がVivado HLSでIPを作っているときに使う機能はほとんど限られている．
Cシミュレーション，HDLの合成，そしてIPの出力である．
これにGUIを使う必要はほとんど感じられない．
makeコマンドでそれらの一連の処理が出来れば楽チンである．

## CUIでVivado HLSを使う

### tclでビルドする

FPGA開発日記のmsyksphinzさんが，tclとmakeを使ってビルドする方法を記事にしていた．

記事：[コマンドラインからVivado HLSを使用するためのスクリプト](http://msyksphinz.hatenablog.com/entry/2016/09/15/020000)

なるほど！
Makefileで環境変数を定義しておいて，tclのスクリプトでそれらを参照すれば，汎用的なMakefileを作れるみたいだ．

このMakefileのターゲットは，allとcleanしかない．
allはCのソースコードをIPに，cleanは生成物やログを削除する．
しかし私はHDLの合成までやって，Cのコードにpragmaを追加してチューニングを行うことがある．
なので場合によっては，HDLの合成までで止めたい．

### makeコマンドでビルドする

私がVivado HLSを使うときのディレクトリ構成に合わせて，Makefileとtclスクリプトを作る．
作ったMakefileとサンプルプロジェクトは[Github](https://github.com/Kenta11/adder)に用意した．
ディレクトリ構成を下に示す

```
adder/
├── Makefile
├── directives.tcl
├── include: 合成する関数のヘッダ
│   └── adder.hpp
├── src: 合成する関数の定義
│   └── adder.cpp
├── test: 合成する関数のテストベンチ
│   ├── include
│   │  └── test_adder.hpp
│   └── src
│       └── test_adder.cpp
└── script: 合成のためのtclスクリプト
     ├── csim.tcl
     ├── csynth.tcl
     ├── cosim.tcl
     └── export.tcl
```

msyksphinzさんの記事を参考に作ったMakefileを下に示す．

```
#### configuration #####

# project and solution name
export HLS_TARGET   = adder
export HLS_SOLUTION = basys3
# source files
export HLS_SOURCE   = $(wildcard src/*)
export HLS_TEST     = $(wildcard test/src/*)

# result
BASE_DIR = $(HLS_TARGET)/$(HLS_SOLUTION)
IP       = $(BASE_DIR)/impl
COSIM    = $(BASE_DIR)/sim
HDL      = $(BASE_DIR)/syn
CSIM     = $(BASE_DIR)/csim

##### targets and commands #####

.PHONY: all
all: $(IP)

.PHONY: export
export: $(IP)
$(IP): $(HDL)
        vivado_hls script/export.tcl

cosim: $(COSIM)
$(COSIM): $(HDL)
        vivado_hls script/cosim.tcl

.PHONY: csynth
csynth: $(HDL)
$(HDL): $(CSIM) $(HLS_SOURCE)
        vivado_hls script/csynth.tcl

.PHONY: csim
csim: $(CSIM)
$(CSIM):
        vivado_hls script/csim.tcl

.PHONY: clean
clean:
        rm -rf $(HLS_TARGET) *.log
```

これでmakeと打てばCのコードからIPが生成される．
またHDLの合成だけやりたい場合は，make csynthと打てば良い．
協調シミュレーション(cosim)は使わない場合もあるので，ターゲットを指定して実行した場合のみ使えるようになっている．

## Makefileとtclスクリプトを自動生成する

新しくプロジェクトを作る場合，先程のMakefileとtclスクリプトをコピーすればよい．
しかしプロジェクトによって変えたい部分がいくつかある．

- Makefile: プロジェクト名とソリューション名
- csynth.tcl: チップ情報とクロック制約

これらの情報を入力として，Makefileとtclスクリプトを生成できるツールを作った↓

[vivado_hls_create_project](https://github.com/Kenta11/vivado_hls_create_project)

### vivado_hls_create_projectの設定

このツールを使うにあたって，設定が2つ必要となる．
１つ目の設定は，Vivadoのパスである．
ホームディレクトリに".vivado_hls_create_project"という名前でVivadoのパスを書いたJSONファイルを置く．
例えば"/opt/Xilinx/Vivado/2018.3"であれば，".vivado_hls_create_project"の内容を以下のようにする．

```
{
    "path_to_vivado": "/opt/Xilinx/Vivado/2018.3"
}
```

２つ目の設定は，vivado\_hls\_create\_projectを使う際にsettings.(sh\|zsh)をsourceすることである．

またこれはオプションだが，Vivado HLSのボードファイルに普段使っているボードの情報を追記しておくと良い．
ボードの情報は(Vivadoをインストールした場所が"/opt/Xilinx/Vivado/2018.3"であれば)，"/opt/Xilinx/Vivado/2018.3/common/config/VivadoHls_boards.xml"にある．
ボード情報を追記する例として，Digilent社のBasys3を追記する場合を以下に示す．

```
<board name="Basys3" display_name="Basys3" family="artix7" part="xc7a35t1cpg236-1"  device="xc7a35t" package="cpg236" speedgrade="-1" vendor="digilentinc.com" />
```

### vivado_hls_create_projectで使えるボードの情報を見る

vivado_hls_create_projectには，Makefileとtclスクリプトを作成できるボードの情報を表示する機能がある．
"vivado_hls_create_project -l"と入力してみると，以下の表示が得られる．
Vivado HLSにデフォルトで登録されているボードだけでなく，追記したBasys3も見えている．

```
$ vivado_hls_create_project -l
Board               Part
----------------------------
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
```

### vivado_hls_create_projectでMakefileとtclスクリプトを生成する

プロジェクト名とボード名を入力して，以下のようにコマンドを入力する．
-pにはプロジェクト名，-bにはボード名(先程-lオプションで表示したもの)を指定する．
するとMakefileとtclスクリプト，そしていくつかのディレクトリが生成される．

includeとsrcはハードウェア化する関数のためのディレクトリ，test以下はテスト用のディレクトリだ．

```
$ vivado_hls_create_project -p adder -b Basys3
INFO:  Found part
INFO:  Generate Makefile
INFO:  Generate directories
INFO:  Generate tcl scripts
$ tree .
.
├── Makefile
├── directives.tcl
├── include
├── script
│   ├── cosim.tcl
│   ├── csim.tcl
│   ├── csynth.tcl
│   └── export.tcl
├── src
└── test
    ├── include
    └── src

6 directories, 6 files
```

ハードウェア化するCコードをinclude, srcに，テストコードをtestに置けば，makeでIPの生成までやってくれる．

## おわりに

これでGUI無しにVivado HLSのプロジェクトを作ったりIPの生成が出来るようになった．
もしこのツールを使いたい人や使ってみた人がいれば，感想や質問等を是非聞かせてほしい．

