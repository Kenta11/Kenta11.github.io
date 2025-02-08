---
title: "Operating System development tutorials in Rust on the Raspberry Pi をする #3"
date: 2023-02-01T22:52:52+09:00
tags: [Rust, Raspberry Pi, Operating System]
---
# はじめに

[前回](../2023-01-31-rust-raspberrypi-os-tutorials)の続きから．

# [03_hacky_hello_world](https://github.com/rust-embedded/rust-raspberrypi-OS-tutorials/tree/master/03_hacky_hello_world)

- QEMU がエミュレートする UART を介して，`println!` マクロで文字列を表示できるようにする
  - `console::console` 関数は `core::fmt::Write` トレイトを実装した構造体を返す (`src/bsp/raspberrypi.rs`)
    - このトレイトは `write_str`, `write_char`, `write_fmt` 関数をもつ
  - `write_str` 関数は UART（アドレスが0x3F201000）に一文字ずつ書き込む (`src/console.rs`)
  - `print!` と `println!` はそれぞれ `write_fmt` 関数を呼び出す（`src/print.rs`）
    - `write_str` を実装すると `write_fmt` も自動的に実装されるのか？

## 実行結果

```shell
$ make

Compiling kernel ELF - rpi3
   Compiling tock-registers v0.8.1
   Compiling mingo v0.3.0 (/home/kenta/Git/Kenta11/rust-raspberrypi-OS-tutorials/03_hacky_hello_world)
   Compiling aarch64-cpu v9.0.0
    Finished release [optimized] target(s) in 3.88s

Generating stripped binary
        Name kernel8.img
        Size 6 KiB
$ make test

Boot test - rpi3
docker: Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Post "http://%2Fvar%2Frun%2Fdocker.sock/v1.24/containers/create": dial unix /var/run/docker.sock: connect: permission denied.
See 'docker run --help'.
make: *** [Makefile:216: test_boot] エラー 126
$ sudo make test
[sudo] kenta のパスワード:

Boot test - rpi3
         -------------------------------------------------------------------
         🦀 Running 1 console I/O tests
         -------------------------------------------------------------------

           1. Checking for the string: 'Stopping here'..................[ok]
         
         Console log:
           Hello from Rust!
           Kernel panic!
           
           Panic location:
                 File 'src/main.rs', line 129, column 5
           
           Stopping here

         -------------------------------------------------------------------
         ✅ Success: Boot test
         -------------------------------------------------------------------


$ sudo make qemu

Launching QEMU
Hello from Rust!
Kernel panic!

Panic location:
      File 'src/main.rs', line 129, column 5

Stopping here.
```
