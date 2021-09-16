# EasyConnect-linux-fix

## 简介

linux版本的EasyConnect安装后无法直接使用，本项目在安装基础上进行修改，以使其能够正常运行。

## 使用

### 安装EasyConnect

正常安装你的学校/公司/组织对应版本的EasyConnect并**尝试启动**。

如果能够正常使用，那无需执行本项目。

如果你遇到：*启动后没有出现界面/尝试连接一段时间后闪退* 等现象，则本项目可能有所帮助。

**我以v7.6.3版本为基准编写的本项目，供参考**

（安装后版本可在 `/usr/share/sangfor/EasyConnect/resources/conf/version.xml`中查看）

### 安装补丁

在合适位置进行执行操作：

```bash
git clone https://github.com/du33169/EasyConnect-linux-fix.git
cd EasyConnect-linux-fix
bash ./EasyConnect-fix.sh
```

运行时会要求输入sudo密码（终端不会显示，输入后回车），该密码用于获取root权限，将会用且仅用于：

- 复制文件到EasyConnect安装目录
- 访问和修改EasyConnect启动器.desktop文件
- 提供EasyMonitor等程序需要的权限

完成后可正常使用启动器快捷方式启动EasyConnect。

**安全警告**：询问用户得到的**sudo密码**将**以明文**写入/usr/share/sangfor/EasyConnect/RunEasyConnect.sh以避免每次启动EasyConnect时终端询问密码。如果有安全需求请**谨慎使用**。

### 卸载

在执行脚本的同时传入uninstall参数即可卸载补丁。

```bash
bash ./EasyConnect-fix.sh uninstall
```

## 原理

以下为该fix项目的原理。如果脚本在你的发行版无法正常工作，可以参考这部分原理并手动操作。

（EasyConnect-linux的安装位置固定为 `/usr/share/sangfor/EasyConnect`）

### 第一步：解决依赖问题

根据DotIN13[这篇博客](https://www.wannaexpresso.com/2020/06/07/easy-connect-manjaro/)，将[libpango](https://packages.debian.org/buster/libpango-1.0-0)、[libpangocairo](https://packages.debian.org/buster/libpangocairo-1.0-0)、[libpangoft](https://packages.debian.org/buster/libpangoft2-1.0-0)版本1.0的软件包中EasyConnect需要的运行库`data.tar.xz/usr/lib/x86_64-linux-gnu/*.so.0.4200.3`以及`*.so.0`提取，并直接复制到EasyConnect的安装目录下即可解决依赖问题（复制操作需要权限）。

**需要指出**的是，其中的\*.so.0.4200.3文件是真正的运行库，而\*.so.0则是指向对应运行库的**软链接**。为了方便安装，在本项目中，需要的动态库已经位于patch目录下。

考虑到软链接在压缩、git拉取等操作时很容易失效，并且指向的只是同一目录下的库文件，本项目附带的patch目录中**直接将各个\*.so.0.4200.3重命名为对应\*.so.0**。

### 第二步：解决sslservice启动问题

DotIN13文章中通过定时启动服务的方式经过实践很难把握时机，Hagb的[这篇笔记](https://github.com/Hagb/docker-easyconnect/blob/master/doc/run-linux-easyconnect-how-to.md)指出ECAgent.log中出现 `cms client connect failed`时为一个关键时刻。此时启动sslservice（`/usr/share/sangfor/EasyConnect/resources/shell/sslservice.sh`）即可正常连接。

patch中的**RunEasyConnect.sh**即解决上述问题的辅助启动脚本，以该脚本代替 `/usr/share/sangfor/EasyConnect/EasyConnect`可执行文件即可正常启动。

**关于最后while循环的笔记**：经过实验sslservice只需启动一次，无需重复；但RunEasyConnect.sh在启动ssl服务后需要等待EasyConnect主进程结束，否则会造成闪退。常用的`wait`命令未起效果，此处暂时采用while循环检测EasyConnect进程并sleep的方法。

### 第三步：启动器修改

EasyConnect的启动器文件安装至 `/usr/share/applications/EasyConnect.desktop`，为了简化启动EasyConnect时的操作，fix脚本修改该文件并将执行前述辅助启动脚本的命令写入（修改操作需要权限），这样就可用启动器以常规方式启动EasyConnect，无需终端操作。

**安全警告**：RunEasyConnect.sh**需要root权限**运行EasyConnect的某些脚本（即使用sudo），目前的fix脚本在修改启动器文件时将询问用户得到的**sudo密码**一并**以明文**写入RunEasyConnect.sh以避免每次启动时终端询问密码。如果有安全需求请**谨慎使用**。

## 声明

- 本项目在[DotIN13](https://www.wannaexpresso.com/2020/06/07/easy-connect-manjaro/)和[Hagb](https://github.com/Hagb/docker-easyconnect/blob/master/doc/run-linux-easyconnect-how-to.md)得到的结果基础上进行简单的整理和自动化得到，特此鸣谢。
- 本项目为第三方补丁，与EasyConnect及Sangfor官方无关。
