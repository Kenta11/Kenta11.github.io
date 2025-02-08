---
title: Vivadoを使用する際にのみVivadoへパスを通す(Zsh編)
date: 2019-02-17 20:00:00 +0900
tags: ["Vivado", "Vivado HLS", "Zsh"]
toc: true
---

settings64.shをsourceしてVivadoへパスを通すと，gccやらcmakeが全てXilinxディレクトリの下にあるものになってしまう．
そこで以前Qiitaにて，Vivadoを使用する際にのみVivadoへパスを通す方法について投稿した．

当該記事：[Vivadoの使用中にのみVivadoへのパスを通す](https://qiita.com/Kenta11/items/2d132a66c599df76639d)

このときはBashを使っていたのだが，私は最近はもっぱらZshを使っている．
Zshであっても同じように，Vivadoを使用する際にのみVivadoへパスを通すことができる．

.zshrcに以下の記述をする．

```zsh
# vivado
function vivado(){
    source /path/to/Xilinx/Vivado/201x.x/settings64.sh

    # activate
    /path/to/Xilinx/Vivado/201x.x/bin/vivado $@

    # remove path
    xilinx_path=(`echo $PATH | tr ":" "\n" | grep "^/path/to/Xilinx"`)
    for ((i = 0; i <= ${#xilinx_path[@]}; i++)); do
        export PATH=`echo -n $PATH | awk -v RS=: -v ORS=: '$0 != "'${xilinx_path[$i]}'"' | sed 's/:$//'`
    done
}

# vivado hls
function vivado_hls(){
    source /path/to/Xilinx/Vivado/201x.x/settings64.sh

    # activate
    /path/to/Xilinx/Vivado/201x.x/bin/vivado_hls $@

    # remove path
    xilinx_path=(`echo $PATH | tr ":" "\n" | grep "^/path/to/Xilinx"`)
    for ((i = 0; i <= ${#xilinx_path[@]}; i++)); do
        export PATH=`echo -n $PATH | awk -v RS=: -v ORS=: '$0 != "'${xilinx_path[$i]}'"' | sed 's/:$//'`
    done
}
```

settings64.shはbashのスクリプトだが，Zshでsourceしても動いた．
"/path/to"の部分はVivadoをインストールしたパスにすること．
"201x.x"も同様に，使っているバージョンに合わせること．

vivadoの呼び出しが絶対パスになっているが，もちろんここを単に"vivado"としないこと．
ここで定義したvivado関数を永久に再帰呼び出しする羽目になる．

