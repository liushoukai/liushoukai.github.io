---
layout: post
title: iTerm2配置Zmodem文件传输
categories: tools
tags: tools macOS
---

在 Windows 上用 XShell、SecureCRT 等工具时，只要在服务端装好 lrzsz 工具包就可以实现方便的文件上传下载；

在 Mac 上用 iTerm 的时候发现 iTerm 原生不支持 rz/sz 命令，也就是不支持 Zmodem 来进行文件传输；

---

### 介绍iterm2-zmodem脚本

---

在Github上作者mmastrac通过脚本实现了对Zmodem的支持，该脚本可用于自动执行从OSX桌面到可运行lrzsz的服务器（理论上，支持SSH的任何计算机）的ZModem传输，反之亦然。

源码地址如下：[https://github.com/mmastrac/iterm2-zmodem][1]{:target="_blank"}

---

### 安装iterm2-zmodem脚本

---

```shell
1.在OSX上安装lrzsz
brew install lrzsz

2.保存脚本至/usr/local/bin目录
wget -P /usr/local/bin https://raw.githubusercontent.com/mmastrac/iterm2-zmodem/master/iterm2-send-zmodem.sh https://raw.githubusercontent.com/mmastrac/iterm2-zmodem/master/iterm2-recv-zmodem.sh

3.设置脚本可执行权限
chmod +x /usr/local/bin/iterm2-send-zmodem.sh /usr/local/bin/iterm2-recv-zmodem.sh

4.配置iTerm2
点击Preferences-> Profiles -> Default -> Advanced -> Triggers的Edit按钮，增加两项配置如下：
Regular expression: rz waiting to receive.\*\*B0100
Action: Run Silent Coprocess
Parameters: /usr/local/bin/iterm2-send-zmodem.sh
Instant: checked

Regular expression: \*\*B00000000000000
Action: Run Silent Coprocess
Parameters: /usr/local/bin/iterm2-recv-zmodem.sh
Instant: checked
```

---

### 参考资料

---

1.[https://github.com/mmastrac/iterm2-zmodem][1]{:target="_blank"}

[1]:https://github.com/mmastrac/iterm2-zmodem
