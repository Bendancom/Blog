#import "/typ/post.typ": post

#show: post.with(
  title: [`Archlinux`安装],
  subtitle: [前期准备],
  authors: ("岑白"),
  description: [`Archlinux`安装具体确实可以看`Arch wiki`，但这实际上仍不够详细],
  date: datetime(year: 2025,month: 1,day: 19),
  lastModDate: none,
  category: "技术",
  tags: ("Linux","安装"),
  order: 0,
  image: none,
  lang: "zh",
)

= 前言

安装 Linux 尤其是 Archlinux 特别需要能够查找资料的能力，但能搜到这篇博客的想必资料查找能力已然过关。本文也只是简要说明，若有详细需求可参阅参考资料。

笔者没有多余的 ARM 架构的手机/电脑，无法实践，因而 ARM 方面会有不全、错漏

若有问题可在 discussion 处留言

= 安装介质种类

== 镜像

从 ArchIso 中安装

适用于U盘插入已完整安装的主板上进行安装。

注：`archiso` 需在 Archlinux 环境下使用

=== 来源


==== X86-64

 - #link("https://archlinux.org/download")[Archlinux Downloads]
 - #link("https://mirrors.aliyun.com/archlinux/iso/latest/")[阿里云镜像站]
 - #link("https://mirrors.ustc.edu.cn/archlinux/iso/latest/")[中国科技技术大学开源镜像站]
 - #link("https://mirrors.tuna.tsinghua.edu.cn/archlinux/iso/latest/")[清华大学开源软件镜像站]
 - 由 #link("https://wiki.archlinux.org/title/Archiso")[archiso] 手动构建镜像，可自定义程度高
 - #link("https://github.com/clsty/arCNiso/releases/latest")[arCNiso]，对简中用户安装进行加强，对设备需求低，可仅触屏下完成安装(能但困难)。
 - #link("https://release.archboot.com/x86_64/latest/iso/")[Archboot]

==== ARM
 
 - #link("https://release.archboot.com/aarch64/latest/iso/")[Archboot]
 - 由 #link("https://wiki.archlinux.org/title/Archiso")[archiso] 手动构建镜像，可自定义程度高

=== 方式

在下载地址中有许多种文件，在此简述文件类别及作用。由文件后缀列举：

- .iso，镜像文件
- .iso.sig 镜像文件签名，可用GPG验证，在此不做展开
- .torrent 镜像文件磁力链接，可用专用BT工具下载，在此不做展开
- .txt 校验文件
- .tar.gz 归档压缩包，里面含有 Archlinux 系统，将之分门别类拷贝到存储中即可完成安装

== 引导程序

从 Bootstrap 安装 Archlinux

适用于直接将系统安装到存储中。

=== 来源

==== X86-64

 - #link("https://archlinux.org/download")[Archlinux Downloads]
 - #link("https://mirrors.aliyun.com/archlinux/iso/latest/")[阿里云镜像站]
 - #link("https://mirrors.ustc.edu.cn/archlinux/iso/latest/")[中国科技技术大学开源镜像站]
 - #link("https://mirrors.tuna.tsinghua.edu.cn/archlinux/iso/latest/")[清华大学开源软件镜像站]

==== ARM

 - #link("https://github.com/biggestT/archlinuxarm-bootstrap")[archlinuxarm-bootstrap]
 - #link("https://archlinuxarm.org/about/downloads")[Archlinux ARM]

=== 方式

在下载地址中有许多种文件，在此简述文件类别及作用。由文件后缀列举：

 - .tar.zst zst压缩格式的打包/归档文件夹，如何解压在此不做展开
 - .tar.zst.sig zst压缩格式的打包/归档文件夹的签名，可用GPG验证，在此不做展开
 - .tar.gz 归档压缩包，如何解压在此不做展开

== 网络

从服务器中安装 Archlinux

适用于统一对多台电脑进行安装（不过适用范围极窄，有这种需求的根本不会去装 Archlinux 这种滚动发行版，因而在本文中仅是列举，不做讲解）。

=== 来源

- #link("https://archlinux.org/releng/netboot")[Arch Linux Netboot]

=== 方式

- iPXE

= 准备安装介质

== 镜像

将 `.iso` 的镜像文件刻录到U盘中

> [!WARNING]
> U盘刻录必定会将其上数据全部删除，一定一定要做好数据备份

> [!NOTE]
> 可使用 Ventoy 镜像实现一次刻录，即无须因 .iso 文件不同而多次刻录 U 盘，详情见主页 #link("https://www.ventoy.net/cn/")[Ventoy]

> [!NOTE]
> Ventoy 适用于 x86 Legacy BIOS、IA32 UEFI、x86_64 UEFI、ARM64 UEFI 和 MIPS64EL UEFI 启动方式。

=== Linux

==== 命令行

```shell
sudo dd bs=4M if=/path/to/file.iso of=/dev/sdX status=progress oflag=sync
```
其中：
 - `/path/to/file.iso` 为所下载的镜像文件
 - `/dev/sdX` 为你要刻录的U盘
 - `4M` 为读写块大小，一般不用更改

==== 图形界面

使用软件如下，不再叙述：

 - `gnome-multi-writer`

=== Windows

操作方法见微软官方文档 #link("https://learn.microsoft.com/zh-cn/windows-hardware/manufacture/desktop/install-windows-from-a-usb-flash-drive?view=windows-11")[从闪存驱动器安装 Windows]

=== MacOS

操作方法见苹果官方文档 #link("https://support.apple.com/zh-cn/guide/disk-utility/dskutl11888/mac")[在 Mac 上使用"磁盘工具"创建磁盘映像]

=== 其它系统

参见官方文档。

== 引导程序

=== Archlinux

使用 `arch-install-scripts` 软件包进行安装

> [!NOTE]
> 其实 Archlinux 的镜像安装就是在U盘上安装一个带有 `arch-install-script` 的 Archlinux 系统。

> [!NOTE]
> X86-64 与 ARM 的区别就在于其最后安装的软件包架构的不同，一个例子：交叉编译

=== Linux

使用引导文件压缩包，在某一目录（推荐`/tmp`）解压后使用 `chroot` 命令进入 `Archlinux` 环境。然后操作就与 `Archlinux` 相同了（通常这类引导包自带了`arch-install-scripts`）

=== MacOS

大概与Linux的操作相同？也可能因为兼容问题而不行

- [ ] 用虚拟机去测试

=== Windows

使用 WSL2 运行 Linux 虚拟机进行操作，之后同 Linux

= 离线安装

几乎所有镜像都需要在网络环境下进行安装，除了`Archboot` 可以离线。
为了使其余镜像也可离线安装，需提前准备要安装的软件包。

=== 软件包

注意安装系统的架构

 - `base` 基础软件包，包含基础的命令
 - `base-devel` 基础构建工具
 - `linux` 系统本体
 - `linux-firmware` 固件，大部分设备都有
 - `sof-firmware` 声卡固件（正常是无须安装的，但有些固件比较偏门）

= 额外内核模块

== ZFS

由于许可证不兼容问题，ZFS文件系统并未内置于内核中。

=== 镜像

要在镜像中添加，可使用 #link("https://github.com/eoli3n/archiso-zfs")[archiso-zfs] 脚本。

或使用 `archiso` 构建带有该内核模块的镜像。

或直接下载该镜像 #link("https://github.com/x0rzavi/archiso-zfs/releases/latest")[archiso-zfs]。

=== 引导程序

需在进行操作的 Linux 系统上安装该模块，安装方法自行查阅。

== APFS

=== 镜像

使用 `archiso` 构建带有该内核模块的镜像。

或直接下载该镜像 #link("https://github.com/Integral-Tech/archiso-apfs/releases/latest")[archiso-apfs]。

=== 引导程序

同 ZFS 引导程序

= 参考资料

#bibliography("refs.yml")
