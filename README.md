# EasyConnect-linux-fix

## 简介

linux版本的EasyConnect安装后无法直接使用，本项目在安装基础上进行修改，以使其能够正常运行。

## 使用

首先正常安装EasyConnect。**目前已测试可行的版本为v7.6.3。**

在合适位置进行执行操作：

``` bash
git clone https://github.com/du33169/EasyConnect-linux-fix.git
cd EasyConnect-linux-fix
./EasyConnect-fix.sh
```

运行时会要求输入sudo密码，详情可见原理部分。

完成后可正常使用启动器快捷方式启动EasyConnect，且不会弹出浏览器窗口（猜测是以高权限运行的缘故）。

## 原理

（EasyConnect-linux的安装位置固定为`/usr/share/sangfor/EasyConnect`）

### 第一步：解决依赖问题

根据DotIN13[这篇文章](https://www.wannaexpresso.com/2020/06/07/easy-connect-manjaro/)，我们将[libpango](https://packages.debian.org/buster/libpango-1.0-0)、[libpangocairo](https://packages.debian.org/buster/libpangocairo-1.0-0)、[libpangoft](https://packages.debian.org/buster/libpangoft2-1.0-0)特定版本的软件包中EasyConnect需要的运行库提取，并直接复制到EasyConnect的安装目录下即可解决（复制操作需要权限）。在本项目中，需要的动态库已经位于patch目录下。

### 第二步：解决sslservice启动问题

DotIN13文章中通过延时启动服务的方式经过实践很难把握时机，Hagb的[这篇文章](https://github.com/Hagb/docker-easyconnect/blob/master/doc/run-linux-easyconnect-how-to.md)指出ECAgent.log中出现`cms client connect failed`时启动sslservice即可正常连接，并给出了对应脚本。

### 第三步：启动器修改

patch中的RunEasyConnect.sh即解决上述问题的辅助启动脚本，以该脚本代替`/usr/share/sangfor/EasyConnect/EasyConnect`可执行文件即可正常启动。

EasyConnect的启动器文件安装至`/usr/share/applications/EasyConnect.desktop`，为了简化操作，fix脚本修改该文件并将以sudo执行上述辅助启动脚本的命令写入（修改操作需要权限），这样就可用启动器以常规方式启动EasyConnect，无需特殊操作。

**注意**：RunEasyConnect.sh**需要root权限**运行（即使用sudo），fix脚本在修改启动器文件时将询问用户得到的**sudo密码**一并写入.desktop文件以避开每次启动时终端询问密码。如果有特殊安全考虑或修改过密码，请自行修改.desktop文件。

## 声明

- 本项目在[DotIN13](https://www.wannaexpresso.com/2020/06/07/easy-connect-manjaro/)和[Hagb](https://github.com/Hagb/docker-easyconnect/blob/master/doc/run-linux-easyconnect-how-to.md)得到的结果基础上进行简单的整理和自动化得到，特此鸣谢。
- 本项目为第三方补丁，与EasyConnect官方无关。

