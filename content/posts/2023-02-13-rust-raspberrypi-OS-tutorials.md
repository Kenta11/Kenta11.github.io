---
title: "Operating System development tutorials in Rust on the Raspberry Pi をする #5"
date: 2023-02-13T23:00:00+09:00
tags: [Rust, Raspberry Pi, Operating System]
---
# はじめに

[前回](../2023-02-02-rust-raspberrypi-os-tutorials)の続きから．

# [05_drivers_gpio_uart](https://github.com/rust-embedded/rust-raspberrypi-OS-tutorials/tree/master/05_drivers_gpio_uart)

## 概要

- UART と GPIO のコントローラ用ドライバを追加する
    - これまでに作成した QEMU コンソールを捨てて， `ドライバマネージャ` を導入する

## ドライバマネージャ

- `ドライバサブシステム` をカーネルに追加
    - 参照：`src/driver.rs`
- `interface::DeviceDriver` トレイトは各デバイスドライバが実装する必要がある

- `crate::driver::driver_manager().init_drivers(...)` はドライバマネージャに全ての登録済みドライバをループさせ，初期化をキックし，オプションの `初期化後コールバック` も実行する

## BSP ドライバ実装

- `src/bsp/raspberrypi/driver.rs` の `init()` が `UART` と `GPIO` の登録の面倒をみる
- ドライバは `src/bsp/device_driver` に保存されており，`BSP` が使用する

- まず `PL011Uart` ドライバを追加する
    - `console::interface::*` トレイトを実装
    - メインシステムのコンソールとして使用
- 次に `GPIO` ドライバを追加する
    - このドキュメントでは Raspberry Pi 3 向けに `Makefile` が書かれている
    - Raspberry Pi 4 向けにビルドする場合は ターゲットに `BSP=rpi4` を指定
        - Raspberry Pi 3 しか持っていないので読み飛ばす
- `BSP` は `src/bsp/raspberrypi/memory.rs` でメモリマップをもつ

## SD カードからブートする

1. `boot` という名前の `FAT32` のパーティションを作成
2. 所定の内容の `config.txt` を作成
3. [Raspberry Pi firmware repo](https://github.com/raspberrypi/firmware/tree/master/ot) から [bootcode.bin](https://github.com/raspberrypi/firmware/raw/master/boot/otcode.bin), [fixup.dat](https://github.com/raspberrypi/firmware/raw/master/boot/xup.dat), [start.elf](https://github.com/raspberrypi/firmware/raw/master/boot/start.f) をコピー
4. `make` を実行
5. `kernel8.img` をSDカードにコピーし，Raspberry Pi に挿入
6. シリアル通信端末で `UART` と接続
7. USB シリアルとホストPCを接続
8. Raspberry Pi を電源に接続し，出力を観察する

## 実行結果

```
$ make

Compiling kernel ELF - rpi3
   Compiling mingo v0.5.0 (/home/kenta/Git/Kenta11/rust-raspberrypi-OS-tutorials/05_drivers_gpio_uart)
   Compiling tock-registers v0.8.1
   Compiling aarch64-cpu v9.0.0
    Finished release [optimized] target(s) in 1.83s

Generating stripped binary
        Name kernel8.img
        Size 10 KiB
$ sudo make qemu
[sudo] kenta のパスワード:

Launching QEMU
[0] mingo version 0.5.0
[1] Booting on: Raspberry Pi 3
[2] Drivers loaded:
      1. BCM PL011 UART
      2. BCM GPIO
[3] Chars written: 117
[4] Echoing input now
```
