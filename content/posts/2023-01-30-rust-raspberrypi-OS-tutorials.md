---
title: "Operating System development tutorials in Rust on the Raspberry Pi をする #1"
date: 2023-01-30T22:30:15+09:00
tags: [Rust, Raspberry Pi, Operating System]
---
# はじめに

Rust で Raspberry Pi 向けのオペレーティングシステムを開発する[チュートリアル](https://github.com/rust-embedded/rust-raspberrypi-OS-tutorials)が公開されている．
早速やってみよう．

# [00_before_we_start](https://github.com/rust-embedded/rust-raspberrypi-OS-tutorials/tree/master/00_before_we_start)

- プロセッサ・アーキテクチャ固有のソースコードは `src/_arch` に配置される
  - 例：`aarch64` 向けのコードは `src/_arch/aarch64` に置かれる
- ボード固有のソースコードは `src/bsp.rs` に書かれる
- 「アーキテクチャとボード」とカーネルは，トレイトで抽象化されたインターフェースで分離される
  - クリーンな抽象を提供する
- boot の流れ
  - エントリポイントは `cpu::boot::arch_boot::_start()` (`src/_arch/__arch_name__/cpu/boot.s`)

# [01_wait_forever](https://github.com/rust-embedded/rust-raspberrypi-OS-tutorials/tree/master/01_wait_forever)

- すべての CPU コアを halt させるプロジェクト
  - Rust コードにはほとんど処理が記述されていない
    - モジュールの定義やアセンブリコード (`src/_arch/aarch64/cpu/boot.rs`)，パニックの定義 (`src/cpu/panic_wait.rs`) など
  - OS は qemu で実行できるようだ
- qemu で OS を動かしてみよう

```
$ make qemu

Compiling kernel ELF - rpi3
   Compiling mingo v0.1.0 (/home/kenta/Git/Kenta11/rust-raspberrypi-OS-tutorials/01_wait_forever)
    Finished release [optimized] target(s) in 0.32s

Generating stripped binary
make: rust-objcopy: そのようなファイルやディレクトリはありません
make: *** [Makefile:130: kernel8.img] エラー 127
```

- `rust-objcopy` が無いと言われた
- `rust-objcopy` は [cargo-binutils](https://github.com/rust-embedded/cargo-binutils) に含まれるコマンドのようだ
  - LLVM のツールチェインを呼び出すコマンドっぽい？
- インストールして再度 OS を動かそう

```
$ cargo install cargo-binutils
（とても時間がかかる）
$ make qemu

Generating stripped binary
        Name kernel8.img
        Size 1 KiB

Launching QEMU
docker: Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?.
See 'docker run --help'.
make: *** [Makefile:155: qemu] エラー 125
```

- docker も動かさないといけないらしい

```
$ sudo systemctl restart docker
$ make qemu

Launching QEMU
docker: Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Post "http://%2Fvar%2Frun%2Fdocker.sock/v1.24/containers/create": dial unix /var/run/docker.sock: connect: permission denied.
See 'docker run --help'.
make: *** [Makefile:155: qemu] エラー 126
```

- 管理者権限まで必要なのか...（docker を使う以上当たり前だが）

```
$ sudo make qemu

Launching QEMU
Unable to find image 'rustembedded/osdev-utils:2021.12' locally
2021.12: Pulling from rustembedded/osdev-utils
7b1a6ab2e44d: Pull complete 
292c6ce995b4: Pull complete 
afb6c3c2887b: Pull complete 
888e016a338b: Pull complete 
59ca2d6f9c6f: Pull complete 
1ac893ad5b73: Pull complete 
008bb9e6650e: Pull complete 
Digest: sha256:9883c96e0e827e35b8d716683f85c7a9b8ffed85422fe418ed080d61e8641e78
Status: Downloaded newer image for rustembedded/osdev-utils:2021.12
----------------
IN: 
0x00000000:  580000c0  ldr      x0, #0x18
0x00000004:  aa1f03e1  mov      x1, xzr
0x00000008:  aa1f03e2  mov      x2, xzr
0x0000000c:  aa1f03e3  mov      x3, xzr
0x00000010:  58000084  ldr      x4, #0x20
0x00000014:  d61f0080  br       x4

----------------
IN: 
0x00000300:  d2801b05  mov      x5, #0xd8
0x00000304:  d53800a6  mrs      x6, mpidr_el1
0x00000308:  924004c6  and      x6, x6, #3
0x0000030c:  d503205f  wfe      
0x00000310:  f86678a4  ldr      x4, [x5, x6, lsl #3]
0x00000314:  b4ffffc4  cbz      x4, #0x30c

----------------
IN: 
0x00000300:  d2801b05  mov      x5, #0xd8
0x00000304:  d53800a6  mrs      x6, mpidr_el1
0x00000308:  924004c6  and      x6, x6, #3
0x0000030c:  d503205f  wfe      
0x00000310:  f86678a4  ldr      x4, [x5, x6, lsl #3]
0x00000314:  b4ffffc4  cbz      x4, #0x30c

----------------
IN: 
0x00000300:  d2801b05  mov      x5, #0xd8
0x00000304:  d53800a6  mrs      x6, mpidr_el1
0x00000308:  924004c6  and      x6, x6, #3
0x0000030c:  d503205f  wfe      
0x00000310:  f86678a4  ldr      x4, [x5, x6, lsl #3]
0x00000314:  b4ffffc4  cbz      x4, #0x30c

----------------
IN: 
0x00080000:  d503205f  wfe      
0x00080004:  17ffffff  b        #0x80000

----------------
IN: 
0x0000030c:  d503205f  wfe      
0x00000310:  f86678a4  ldr      x4, [x5, x6, lsl #3]
0x00000314:  b4ffffc4  cbz      x4, #0x30c

----------------
IN: 
0x0000030c:  d503205f  wfe      
0x00000310:  f86678a4  ldr      x4, [x5, x6, lsl #3]
0x00000314:  b4ffffc4  cbz      x4, #0x30c

----------------
IN: 
0x0000030c:  d503205f  wfe      
0x00000310:  f86678a4  ldr      x4, [x5, x6, lsl #3]
0x00000314:  b4ffffc4  cbz      x4, #0x30c
```

- 0x80000 番地で無限ループをしていることが分かる
- それ以外の命令で何をしているのかが分からない
  - Raspberry Pi 3B+ に搭載された SoC は4コア構成なので，使わないコアも（0x30C-0x314 番地で）無限ループしている？

- 分からないところがかなりあるが，進めていくうちに分かるかもしれない
- とりあえず次に進もう
