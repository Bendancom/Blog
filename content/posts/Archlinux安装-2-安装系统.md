---
title: "Archlinux安装-2-安装系统"
date: 2025-01-19T00:30:00+08:00
lastmod: 2025-01-19T00:30:00+08:00
draft: true
categories: ["Archlinux 安装","Archlinux"]
keywords: "Archlinux Install"
tags: ["ArchLinux","Install","安装","准备","Prepare"]
---

Archlinux 的安装网上是有详细的教程，但不算特别全面，因而本合集在此进行汇总。

本文只讲解了 Archlinux 系统的安装。
<!--more-->

## 前言

Archlinux安装对于镜像或引导程序而言，其主要步骤并无区别。因而本文默认读者已进入 Archlinux 环境。

## 存储介质分区

通常而言就是硬盘，但还有一些其他分类的（TF卡、SD卡等），所以在文中使用存储介质一词。

该步骤并不对 Archlinux 环境有要求。

### 创建分区

#### 必须

 - ROOT 分区

#### 可选

 - EFI 分区，若是多系统可不创建（因为已经有了）
 - BOOT 分区，用于存放 Linux启动文件，通常是否创建由以下几个因素决定：
    - 使用传统 BIOS 系统引导
    - 根目录需要加密或使用复杂的文件系统（如Btrfs、zfs）
    - 系统管理与维护性（与根目录隔离）
    - 硬件或固件限制
 - SWAP 分区，用于虚拟内存，通常由以下几个因素决定：
    - 物理内存不够大
    - 是否设置休眠
 - HOME 分区，用于用户存储，通常由以下几个因素决定：
    - 系统管理与维护性（与根目录隔离）

## 参考资料

[1] [Nakano Miku，ice-kylin，wuhang2003，等.archlinux 简明指南[EB/OL].GitHub.2024-10-09.https://arch.icekylin.online](https://arch.icekylin.online)  
[2] [Installation guide[DB/OL].ArchlinuxWiki.2024-09-30.https://wiki.archlinux.org/title/Installation_guide](https://wiki.archlinux.org/title/Installation_guide)  
[3] [vconlln.Archlinux安装(超详细)[EB/OL].博客园.2023-01-23.https://www.cnblogs.com/vconlln/p/17065420.html](https://www.cnblogs.com/vconlln/p/17065420.html)  
[4] [Arch Linux安装教程 （以Legacy BIOS为例）[EB/OL].极客学习笔记.2022-07-03.https://geekdaxue.co/read/microsoftxiaoice@archlinux/ahdvik#54nlwi](https://geekdaxue.co/read/microsoftxiaoice@archlinux/ahdvik#54nlwi)  
[5] [Install Arch Linux from existing Linux[DB/OL].ArchlinuxWiki.2024-07-29.https://wiki.archlinux.org/title/Install_Arch_Linux_from_existing_Linux](https://wiki.archlinux.org/title/Install_Arch_Linux_from_existing_Linux)  
[6] [王帅.WSL2 安装 ArchLinux —— In The Arch Way[EB/OL].2023-03-13.https://www.devws.cn/posts/wsl2-archlinux](https://www.devws.cn/posts/wsl2-archlinux)  
[7] [Zero___________.iPXE 学习 部署Linux/Windows系统 支持IPv4/IPv6[EB/OL].CSDN.2024-02-01.https://blog.csdn.net/Zero___________/article/details/135866160](https://blog.csdn.net/Zero___________/article/details/135866160)
[8] [DreamOneX.利用Bootstrap从已有的Linux发行版上安装ArchLinux[EB/OL].2022-07-21.https://blog.dreamonex.eu.org/p/2022/07/install-arch-from-linux/#%E5%87%86%E5%A4%87resolvconf](https://blog.dreamonex.eu.org/p/2022/07/install-arch-from-linux/#%E5%87%86%E5%A4%87resolvconf)
[9] [Dontla.操作系统分区的时候/boot和/boot/efi有什么区别？为什么有时需要/boot分区有时不需要？[EB/OL].2025-01-08.https://blog.csdn.net/Dontla/article/details/139780558](https://blog.csdn.net/Dontla/article/details/139780558)
[10] [佚名.Ubuntu系统深度解析：swap空间与休眠模式的优化与配置[EB/OL].2024-12-29.https://www.oryoy.com/news/ubuntu-xi-tong-shen-du-jie-xi-swap-kong-jian-yu-xiu-mian-mo-shi-de-you-hua-yu-pei-zhi.html](https://www.oryoy.com/news/ubuntu-xi-tong-shen-du-jie-xi-swap-kong-jian-yu-xiu-mian-mo-shi-de-you-hua-yu-pei-zhi.html)
