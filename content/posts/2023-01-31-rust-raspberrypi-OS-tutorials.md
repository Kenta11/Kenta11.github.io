---
title: "Operating System development tutorials in Rust on the Raspberry Pi をする #2"
date: 2023-01-31T22:17:41+09:00
tags: [Rust, Raspberry Pi, Operating System]
---
# はじめに

[前回](../2023-01-30-rust-raspberrypi-os-tutorials)の続きから．

# [02_runtime_init](https://github.com/rust-embedded/rust-raspberrypi-OS-tutorials/tree/master/02_runtime_init)

- `_start` で主記憶の初期化を行う
- 初期化後に `_start_rust`（`src/_arch/aarch64/cpu/boot.rs`）にエントリし，`kernel_init`（`src/main.rs`）を実行する

## セクションの構成

- DRAM の先頭アドレスは 0x80000
- 以下，リンカスクリプトで指定されているセクション

- .boot_core_stack：boot 用のスタック？
- .text：機械語命令列
- .rodata：read-only データ．8バイトアラインされている．
- .data：読み書き可能なデータ領域．初期化されない．
- .bss：読み書き可能なデータ領域．初期化される．16バイトアラインされている．
- .got：何に使うのか分からない

## boot.rs

- `MPIDR_EL1`：`PE (Processor Element)` を識別するためのレジスタ
- `CONST_CORE_ID_MASK` は `src/_arch/aarch64/cpu/boot.rs` で定義されている定数か
  - 0b11 なので 3番目の PE が boot core として初期化処理を行う
  - 他の PE は `L_parking_loop` で無限ループ（=何もさせない）
- x0, x1 レジスタにそれぞれ `__bss_start`, `__bss_end_exclusive` をセット
- .bss をゼロ埋め
  - アセンブリ命令：`stp	xzr, xzr, [x0], #16`
    - stp: レジスタペアの内容を主記憶に書き込み
    - xzr: ゼロレジスタ
    - \[x0\]: 書き込み先のポインタ
    - #16: 書き込み先アドレスへのオフセット
      - stp 命令による書き込み後，x0 += 16 される
- `.L_prepare_rust` 以降
  - スタックポインタを機械語命令列の先頭へセット
  - `_start_rust` へ分岐

# 実行結果

```
$ make

Compiling kernel ELF - rpi3
   Compiling tock-registers v0.8.1
   Compiling mingo v0.2.0 (/home/kenta/Git/Kenta11/rust-raspberrypi-OS-tutorials/02_runtime_init)
   Compiling aarch64-cpu v9.0.0
    Finished release [optimized] target(s) in 5.86s

Generating stripped binary
        Name kernel8.img
        Size 1 KiB
$ sudo make qemu

Launching QEMU
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
0x00080000:  d53800a0  mrs      x0, mpidr_el1
0x00080004:  92400400  and      x0, x0, #3
0x00080008:  58000241  ldr      x1, #0x80050
0x0008000c:  eb01001f  cmp      x0, x1
0x00080010:  540001a1  b.ne     #0x80044

----------------
IN: 
0x0000030c:  d503205f  wfe      
0x00000310:  f86678a4  ldr      x4, [x5, x6, lsl #3]
0x00000314:  b4ffffc4  cbz      x4, #0x30c

----------------
IN: 
0x00080014:  d503201f  nop      
0x00080018:  10000440  adr      x0, #0x800a0
0x0008001c:  d503201f  nop      
0x00080020:  10000401  adr      x1, #0x800a0
0x00080024:  eb01001f  cmp      x0, x1
0x00080028:  54000060  b.eq     #0x80034

----------------
IN: 
0x00080034:  d503201f  nop      
0x00080038:  10fffe40  adr      x0, #0x80000
0x0008003c:  9100001f  mov      sp, x0
0x00080040:  14000008  b        #0x80060

----------------
IN: 
0x00080060:  94000004  bl       #0x80070

----------------
IN: 
0x00080070:  94000004  bl       #0x80080

----------------
IN: 
0x00080080:  97fffffe  bl       #0x80078

----------------
IN: 
0x00080078:  94000006  bl       #0x80090

----------------
IN: 
0x00080090:  d503205f  wfe      
0x00080094:  17ffffff  b        #0x80090
```

# 感想

- Rust コードを実行できるようになったので，いよいよ Rust で書いた OS の機能で遊べそうだ
- stp が一命令で色々できることにビックリした
  - MIPS や RISC-V の方が慣れているので，ARM が CISC プロセッサのように思えてしまう
