---
layout: post
title: Linux 发行版 Ubuntu
categories: linux
tags: linux-distribution ubuntu
---

### Ubuntu自动安裝安全更新

---

```shell
# 自动安装安全更新
sudo dpkg-reconfigure -plow unattended-upgrades

# 手动安装安全更新
sudo unattended-upgrade -v
sudo apt-get update
sudo apt-get upgrade

# 出现错误修复方式如下：
sudo dpkg --configure -a
dpkg: error: dpkg status database is locked by another process
sudo lsof /var/lib/dpkg/lock
ps cax | grep 3334
sudo kill 3334
ps cax | grep 3334
ll /var/lib/dpkg/lock
sudo rm /var/lib/dpkg/lock
sudo dpkg --configure -a
```

---

### Ubuntu PPA

---

PPA (Personal Package Archive) 允许应用程序开发人员和 Linux 用户创建自己的存储库来分发软件。 通过 PPA，您可以轻松获得无法在 Ubuntu 官方仓库获得的软件版本。

注意⚠️：`PPA is for Ubuntu >= 14.04`.

```shell
# 使用 PPA 安装 shadowsocks 客户端
sudo add-apt-repository ppa:hzwhuang/ss-qt5
sudo apt-get update
sudo apt-get install shadowsocks-qt5
```

---

### Ubuntu 软件版本管理工具

---

```shell
# 列出版本
sudo update-alternatives --list java

# 选择版本
sudo update-alternatives --config java

# 安装版本
sudo update-alternatives --install /usr/local/java java /data/service/jdk1.8.0_77 2000

# 移出版本
sudo update-alternatives --remove java /data/service/jdk1.8.0_77
```

---

### Ubuntu 安装 gnome-system-tools

---

GNOME System Tools

Formerly known as the Ximian Setup Tools, the GST are a fully integrated set of tools aimed to make easy the job that means the computer administration on an UNIX or Linux system. They're thought to help from the new Linux or UNIX user to the system administrators. The GNOME System Tools are free software, licensed under the terms of the GNU General Public License.

```shell
sudo apt-get -y install gnome-system-tools
```

---

### Ubuntu 桌面版处理TTY7终端卡死

---

Ubuntu桌面环境：GNOME 3.26、Utility

1. Ctrl +Alt+F1  转到 tty1
2. ps -t tty7  查看 tty7 的进程
3. 找到 tty7 的进程PID号  xxx
4. 尝试结束进程sudo kill xxx，无效，则使用sudo kill -9 xxx
5. 自动重启图形界面！

---

### Ubuntu 桌面版点击图标最小化

---

```shell
gsettings set org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/ launcher-minimize-window true
```

---

### Ubuntu 桌面版配置截屏

---

Ubuntu 桌面版中截图命令是`gnome-screenshot .`，可以在终端输入`gnome-screenshot -h`来查看该命令的用法。

用法：

```shell
gnome-screenshot [选项...] 抓取屏幕的图片
帮助选项：
-h, –help 显示帮助选项
–help-all 显示全部帮助选项
–help-gtk 显示 GTK+ 选项
应用程序选项：
-w, –window 抓取窗口，而不是整个屏幕
-a, –area 抓取屏幕的一个区域，而不是整个屏幕
-b, –include-border 抓图中包含窗口边框
-B, –remove-border 去除屏幕截图的窗口边框
-d, –delay=秒 在指定延迟后抓图[以秒计]
-e, –border-effect=效果 添加到边框的特效(阴影、边框或无特效)
-i, –interactive 交互式设定选项
–display=显示 要使用的 X 显示
```

我们常用到的截图选项是截取某个区域的，因此不妨给它设置一个快捷键。

怎么设置快捷键呢？假设，我想要按下Ctrl + Alt + A 来实现区域截图。

1. 依次打开【system settings】（系统设置）–》【keyboard】(键盘)–》【shortcuts】（快捷键）–》【custom shortcuts】（自定义快捷键）
2. 点击那个加号"+"，在【name】输入 screenshot , 【command】输入 gnome-screenshot -a ，点击【apply】确定后，再点击disable；
3. 接着就同时按下 Ctrl+Alt +A 就可以成功设置截图快捷键了。

---

### Ubuntu桌面版添加快捷方式

---

1.添加IntelliJ桌面快捷方式

```shell
创建文件
sudo vim /usr/share/applications/jetbrains-idea.desktop
```

2.添加内容

```shell
[Desktop Entry]
Version=1.0
Type=Application
Name=IntelliJ IDEA
Icon=/data/service/idea-IU-162.2228.15/bin/idea.png
Exec="/data/service/idea-IU-162.2228.15/bin/idea.sh" %f
Comment=The Drive to Develop
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-idea
```

3.修改权限

```shell
sudo chmod 644 /usr/share/applications/jetbrains-idea.desktop
sudo chown root:root /usr/share/applications/jetbrains-idea.desktop
```

---

### 参考资料

---

1. [https://help.ubuntu.com/community/AutomaticSecurityUpdates][1]{:target="_blank"}

[1]:https://help.ubuntu.com/community/AutomaticSecurityUpdates