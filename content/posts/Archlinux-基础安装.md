---
title: "Archlinux-基础安装"
date: 2024-10-19T23:00:00+08:00
lastmod: 2024-10-19T23:00:00+08:00
draft: true
categories: ["Archlinux"]
keywords: "Archlinux Install"
tags: ["ArchLinux","Install","安装"]
---

Archlinux 的安装网上是有详细的教程，但不算特别全面，因而本文在此进行汇总。
<!--more-->

## 前言

安装 Linux 尤其是 Archlinux 特别需要能够查找资料的能力，但能搜到这篇博客的想必资料查找能力已然过关。

## 准备安装介质

### 镜像

从 ArchIso 中安装

适用于在主板中启动安装

#### 来源

- [Archlinux Downloads](https://archlinux.org/download)
- [阿里云镜像站](https://mirrors.aliyun.com/archlinux/iso/latest/)
- [中国科技技术大学开源镜像站](https://mirrors.ustc.edu.cn/archlinux/iso/latest/)
- [清华大学开源软件镜像站](https://mirrors.tuna.tsinghua.edu.cn/archlinux/iso/latest/)
- 由 [archiso](https://wiki.archlinux.org/title/Archiso) 手动构建镜像，可自定义程度高
- [arCNiso](https://github.com/clsty/arCNiso/releases/latest)，对简中用户安装进行加强，对设备需求低，可仅触屏下完成安装(能但困难)。

#### 方式

在下载地址中有许多种文件，在此简述文件类别及作用。由文件后缀列举：

- .iso，镜像文件
- .iso.sig 镜像文件签名，可用GPG验证，在此不做展开
- .torrent 镜像文件磁力链接，可用专用BT工具下载，在此不做展开
- .txt 校验文件

### 脚本

从 Bootstrap 安装 Archlinux

适用于安装到硬盘中

#### 地址

- [Archlinux Downloads](https://archlinux.org/download)
- [阿里云镜像站](https://mirrors.aliyun.com/archlinux/iso/latest/)
- [中国科技技术大学开源镜像站](https://mirrors.ustc.edu.cn/archlinux/iso/latest/)
- [清华大学开源软件镜像站](https://mirrors.tuna.tsinghua.edu.cn/archlinux/iso/latest/)
- arch-install-script(pacman 中)

#### 方式

在下载地址中有许多种文件，在此简述文件类别及作用。由文件后缀列举：

- .tar.zst zst压缩格式的打包/归档文件夹，如何解压在此不做展开
- .tar.zst.sig zst压缩格式的打包/归档文件夹的签名，可用GPG验证，在此不做展开

### 网络

从服务器中安装 Archlinux

#### 地址

- [Arch Linux Netboot](https://archlinux.org/releng/netboot)

#### 方式

- iPXE

## 参考资料

[1] [Nakano Miku，ice-kylin，wuhang2003，等.archlinux 简明指南[EB/OL].GitHub.2024-10-09.https://arch.icekylin.online](https://arch.icekylin.online)  
[2] [Installation guide[DB/OL].ArchlinuxWiki.2024-09-30.https://wiki.archlinux.org/title/Installation_guide](https://wiki.archlinux.org/title/Installation_guide)  
[3] [vconlln.Archlinux安装(超详细)[EB/OL].博客园.2023-01-23.https://www.cnblogs.com/vconlln/p/17065420.html](https://www.cnblogs.com/vconlln/p/17065420.html)  
[4] [Arch Linux安装教程 （以Legacy BIOS为例）[EB/OL].极客学习笔记.2022-07-03.https://geekdaxue.co/read/microsoftxiaoice@archlinux/ahdvik#54nlwi](https://geekdaxue.co/read/microsoftxiaoice@archlinux/ahdvik#54nlwi)  
[5] [Install Arch Linux from existing Linux[DB/OL].ArchlinuxWiki.2024-07-29.https://wiki.archlinux.org/title/Install_Arch_Linux_from_existing_Linux](https://wiki.archlinux.org/title/Install_Arch_Linux_from_existing_Linux)  
[6] [王帅.WSL2 安装 ArchLinux —— In The Arch Way[EB/OL].2023-03-13.https://www.devws.cn/posts/wsl2-archlinux](https://www.devws.cn/posts/wsl2-archlinux)  
[7] [Zero___________.iPXE 学习 部署Linux/Windows系统 支持IPv4/IPv6[EB/OL].CSDN.2024-02-01.https://blog.csdn.net/Zero___________/article/details/135866160](https://blog.csdn.net/Zero___________/article/details/135866160)
