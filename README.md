# EasyConnect-linux-fix

## 简介

linux版本的EasyConnect安装后无法直接使用，本项目在安装基础上进行修改，以使其能够正常运行。

## 使用

首先正常安装EasyConnect。**目前已测试可行的版本为v7.6.3。**

注意：EasyConnect的版本以你所在学校/组织/公司提供的为准，可在 `/usr/share/sangfor/EasyConnect/resources/conf/version.xml`中查看。

### 安装

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

### 卸载

传入uninstall参数即可卸载补丁。

```bash
bash ./EasyConnect-fix.sh uninstall
```

## 原理

（EasyConnect-linux的安装位置固定为 `/usr/share/sangfor/EasyConnect`）

### 第一步：解决依赖问题

根据DotIN13[这篇文章](https://www.wannaexpresso.com/2020/06/07/easy-connect-manjaro/)，将[libpango](https://packages.debian.org/buster/libpango-1.0-0)、[libpangocairo](https://packages.debian.org/buster/libpangocairo-1.0-0)、[libpangoft](https://packages.debian.org/buster/libpangoft2-1.0-0)特定版本的软件包中EasyConnect需要的运行库提取，并直接复制到EasyConnect的安装目录下即可解决依赖问题（复制操作需要权限）。在本项目中，需要的动态库已经位于patch目录下。

### 第二步：解决sslservice启动问题

DotIN13文章中通过延时启动服务的方式经过实践很难把握时机，Hagb的[这篇文章](https://github.com/Hagb/docker-easyconnect/blob/master/doc/run-linux-easyconnect-how-to.md)指出ECAgent.log中出现 `cms client connect failed`时启动sslservice即可正常连接，并给出了对应脚本。

### 第三步：启动器修改

patch中的RunEasyConnect.sh即解决上述问题的辅助启动脚本，以该脚本代替 `/usr/share/sangfor/EasyConnect/EasyConnect`可执行文件即可正常启动。

EasyConnect的启动器文件安装至 `/usr/share/applications/EasyConnect.desktop`，为了简化操作，fix脚本修改该文件并将执行上述辅助启动脚本的命令写入（修改操作需要权限），这样就可用启动器以常规方式启动EasyConnect，无需特殊操作。

**可能的安全风险**：RunEasyConnect.sh**需要root权限**运行EasyConnect的某些脚本（即使用sudo），目前的fix脚本在修改启动器文件时将询问用户得到的**sudo密码**一并**以明文**写入RunEasyConnect.sh以避免每次启动时终端询问密码。如果有安全需求请**谨慎使用**。

## 声明

- 本项目在[DotIN13](https://www.wannaexpresso.com/2020/06/07/easy-connect-manjaro/)和[Hagb](https://github.com/Hagb/docker-easyconnect/blob/master/doc/run-linux-easyconnect-how-to.md)得到的结果基础上进行简单的整理和自动化得到，特此鸣谢。
- 本项目为第三方补丁，与EasyConnect官方无关。
