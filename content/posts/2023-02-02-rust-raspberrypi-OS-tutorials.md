---
title: "Operating System development tutorials in Rust on the Raspberry Pi をする #4"
date: 2023-02-02T21:00:00+09:00
tags: [Rust, Raspberry Pi, Operating System]
---
# はじめに

[前回](../2023-02-01-rust-raspberrypi-os-tutorials)の続きから．

# [04_safe_globals](https://github.com/rust-embedded/rust-raspberrypi-OS-tutorials/tree/master/04_safe_globals)

## 概要

- 疑似ロックを導入する話
- global data structure に対して安全にアクセスするための OS 同期プリミティブの showcase（ショーケースってなんだろう）

- safe Rust では `static mut` なグローバル変数を定義できないので，この章で排他制御の機能を導入し，変更可能なグローバル変数を実現する

## 実行結果

```shell
$ make

Compiling kernel ELF - rpi3
   Compiling mingo v0.4.0 (/home/kenta/Git/Kenta11/rust-raspberrypi-OS-tutorials/04_safe_globals)
   Compiling tock-registers v0.8.1
   Compiling aarch64-cpu v9.0.0
    Finished release [optimized] target(s) in 6.09s

Generating stripped binary
        Name kernel8.img
        Size 7 KiB
$ sudo make test
[sudo] kenta のパスワード:

Boot test - rpi3
         -------------------------------------------------------------------
         🦀 Running 1 console I/O tests
         -------------------------------------------------------------------

           1. Checking for the string: 'Stopping here'..................[ok]
         
         Console log:
           [0] Hello from Rust!
           [1] Chars written: 22
           [2] Stopping here

         -------------------------------------------------------------------
         ✅ Success: Boot test
         -------------------------------------------------------------------

$ sudo make qemu

Launching QEMU
[0] Hello from Rust!
[1] Chars written: 22
[2] Stopping here.
```
