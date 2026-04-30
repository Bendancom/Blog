#import "/typ/post.typ": post

#show: post.with(
  title: [`Archlinux`安装],
  subtitle: [安装系统],
  authors: ("岑白"),
  description: [`Archlinux`安装具体确实可以看`Arch wiki`，但这实际上仍不够详细],
  date: datetime(year: 2025,month: 2,day: 5),
  lastModDate: none,
  category: "技术",
  tags: ("Linux","安装"),
  order: 1,
  image: none,
  lang: "zh",
)

= 前言

Archlinux安装对于镜像或引导程序而言，其主要步骤并无区别。

= 存储介质分区

通常而言就是硬盘，但还有一些其他分类的（TF卡、SD卡等），所以在文中使用存储介质一词。

== 创建分区

在这一步时应去查阅主板的引导程序（Bootloader）类型及方式，以确定所需创建在存储介质上的启动分区的文件系统类型与格式。

不同设备的引导程序：
 - Legecy BIOS —— MBR分区格式存储介质
 - UEFI —— GPT 分区格式存储介质
 - U-Boot —— 一些嵌入式开发板下
 - LLB —— Apple Sillon 下的苹果设备

注： MacOS 仍保有 UEFI 启动方式

=== 必须

 - ROOT 分区
 - 启动分区，至少需要一个

注： 多系统已有一个启动分区，所以可以不创建

=== 可选

 - BOOT 分区，用于存放 Linux启动文件，通常是否创建由以下几个因素决定：
   - 根目录需要加密或使用复杂的文件系统（如Btrfs、zfs）
   - 系统管理与维护性（与 EFI/BIOS 隔离）
   - 硬件或固件限制
 - SWAP 分区，用于虚拟内存，通常由以下几个因素决定：
   - 物理内存不够大
   - 是否设置休眠
 - HOME 分区，用于用户存储，通常由以下几个因素决定：
   - 系统管理与维护性（与根目录隔离）

注： 可选的分区不只有这些，自行根据自身需求去创建

== 格式化分区

 - SWAP 分区 —— 以 swap 的格式 格式化
 - 启动分区 —— FAT32

其余分区无特殊文件系统要求。

> [!NOTE]
> 但得要内核支持该文件系统

== 挂载分区

`/mnt` 为临时挂载目录

 - ROOT 分区 —— `/mnt`
 - EFI 分区 —— `/mnt/boot` 或 `/mnt/efi` == `/mnt/boot/efi`
 - HOME 分区 —— `/mnt/home`
 - SWAP 分区 —— swap 挂载

= 安装 linux 及软件包

进入 Archlinux 环境中。
使用 `pacstrap` 向挂载的分区安装(位于 `arch-install-scripts` 软件包内)

或将相应架构的 Archlinux 系统压缩包解压写入相对应存储介质分区中

== 必须

 - `base`
 - `base-devel`
 - `linux`
 - `linux-firmware`

== 可选

 - `linux-header`，linux系统头文件，用于 dkms 的编译
 - `sof-firmware`，声卡固件
 - `btrfs-progs`，BtrFS 文件系统工具
 - `apfs-progs`，APFS 文件系统工具
 - `linux-apfs-rw` APFS 文件系统支持（实验性写入）
 - `zfs-dkms`，ZFS 文件系统支持
 - `network-manager`，网络管理工具
 - `vim`/`neovim` 等系列终端编辑器
 - `zsh`/`bash` 等系列 shell
 - `tldr`/`man` 帮助手册

注： 可选软件包只是列举一些常用软件，并不一定符合安装者的习惯，自行根据需求进行增减。

== 引导程序

 - `efibootmgr`，管理一级引导程序（UEFI）启动序列，生成 .efi 文件用于 UEFI 启动
 - `grub`/`rEFInd`/`OpneCore`/`Clover` #link("https://cn.linux-terminal.com/?p=1040")[等]，二级引导程序，管理多系统的选择

> [!NOTE]
> 在前面笔者标明 BOOT 分区为可选，是因为有统一内核映像(UKI)，可以将内核打包为一个 .efi 文件用于启动，所以只要内核支持的文件系统都能启动

== 微码

根据 CPU 芯片制造商安装

= 生成 fstab

```shell
genfstab -U /mnt > /mnt/etc/fstab
```
具体参数用途查阅手册
推荐用存储介质 UUID 生成（因为其唯一对应）

= 杂项

 - 同步时间
 - 设置语言
 - 设置主机名与时区

#bibliography("refs.yml")
