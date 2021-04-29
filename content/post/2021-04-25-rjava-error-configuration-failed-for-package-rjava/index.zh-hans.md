---
title: 'Using R: rJava 安装失败小记——ERROR: configuration failed for package ‘rJava’'
author: Han Chen
date: '2021-04-25'
slug: []
categories:
  - Using R for Everything
tags:
  - package
  - R
  - install.package
  - rJava
---
[`rJava`](https://CRAN.R-project.org/package=rJava) 是 R 语言中经常会遇到的依赖包，例如使用 [`xlsx`](https://cran.r-project.org/package=xlsx) 包便需要 `rJava` 依赖（[`readxl`](https://CRAN.R-project.org/package=readxl)也是不错的选择）， 然而安装 `rJava`很难不让人感觉：rJava, an interface to nightmere instead an interface for R to use java.

所以我尝试总结目前遇到的安装并配置 rJava 过程中遇到的那些坑，为自己做个记录，如果对任何人有任何帮助那就更好了。本文中以 macOS 为示例，然而绝大多数操作对于 Linux 也有效，虽然 Windows 具体方法基本不同，但其中思路也可作为参考。

## 加载 R Package 的障碍居然是 Java？

噩梦的开始，通常是发现忘了安装 JDK（[什么是 JDK](https://www.runoob.com/w3cnote/the-different-of-jre-and-jdk.html)），例如安装成功，但加载包失败

`library(xlsx)`：

> Error: package or namespace load failed for 'xlsx':
> .onLoad failed in loadNamespace() for 'rJava', details:
> call: fun(libname, pkgname)
> error: JVM could not be found
> In addition: Warning messages:
> 1: In system("/usr/libexec/java_home", intern = TRUE) :
> running command '/usr/libexec/java_home' had status 1
> 2: In fun(libname, pkgname) :
> Cannot find JVM library 'NA/lib/server/libjvm.dylib'
> Install Java and/or check JAVA_HOME (if in doubt, do NOT set it, it will be detected)
> The operation couldn’t be completed. Unable to locate a Java Runtime.
> Please visit http://www&#46;java&#46;com for information on installing Java.

或者问题出现在安装包的步骤，错误提示可能是：

> ERROR: configuration failed for package ‘rJava’

## Step 1. 安装 JDK

在决定安装 JDK 之前，建议首先检查一下是否真的没有安装 JDK 以及 JDK 的版本，在 macOS 或 Linux 中的 Terminal （或者 RStudio 的 **Terminal 标签**，**Terminal 标签**，**Terminal 标签**）中运行下述命令

```shell
$ java -version
The operation couldn’t be completed. Unable to locate a Java Runtime.
Please visit http://www.java.com for information on installing Java.
```

![在 Terminal 标签中](https://cdn.jsdelivr.net/gh/womeimingzi11/self-image/CleanShot%202021-04-25%20at%2001.17.35%402x.png)

如果没有返回 Java Runtime 的版本或者或者 JDK 版本较高，通常我们可以尝试安装 JDK8，至于为什么是 JDK8 而不是更新的版本，我们后面会讲到。

对于 macOS，我建议使用Homebrew 安装 JDK，Homebrew 是什么以及如何安装请参考[清华大学 brew 镜像说明](https://mirrors.tuna.tsinghua.edu.cn/help/homebrew/)。

在 `AdoptOpenJDK/openjdk`这个Homebrew 的 Tap 源中提供了较为丰富的 JDK 版本，基本能够满足需求。至于为什么选择 AdoptOpenJDK，为什么不选择 OracleJDK，以及为什么不选择任何其他版本的 JDK 这里就不做讨论了——有需求的朋友一定能更优雅的解决 rJava 的问题吧。

通过 Homebrew 安装 AdoptOpenJDK 8 的命令如下（Terminal 中运行）：

```shell
# Activate the AdoptOpenJDK tap
brew tap AdoptOpenJDK/openjdk
# Install the desired version
brew cask install adoptopenjdk8
```

在 Debian 及 Debian 衍生的 Linux 中，例如 Ubuntu/Debian 等可以使用下列命令:

```shell
sudo apt-get install openjdk-8-jdk
```

安装成功后再次检查 JDK 版本——1.8.X 就代表 JDK8 成功安装了。

```shell
$ java -version
openjdk version "1.8.0_292"
OpenJDK Runtime Environment (AdoptOpenJDK)(build 1.8.0_292-b10)
OpenJDK 64-Bit Server VM (AdoptOpenJDK)(build 25.292-b10, mixed mode)
```

此时再返回 R 的 Console 中加载之前报错的包，我有 90% 的信心认为你不会再遇到问题了！

## Step 2. `R CMD autoconf`

然而，最尴尬的事情并不是 JDK 没有安装，而是 **JDK 安装了，可就是/还是要花式报错……**

相信这也是从网上搜到这篇文章的朋友的最大的困扰，这个问题通常是因为 R 没有正确的识别到电脑上的 JDK，想要解决这个问题也不算太难，网络上大量的教程都会建议尝试在 Terminal 中运行 `R CMD autoconf`，你以为的是问题解决了，然而通常你遇到的是：

> checking whether JNI programs can be compiled... configure: error: Cannot compile a simple JNI program. See config.log for details.

或者

> Make sure you have Java Development Kit installed and correctly registered in R.
> If in doubt, re-run "R CMD javareconf" as root.

既然系统给出了这个提示，那不妨尝试一下他给出的解决方案：在 Terminal 中运行`R CMD javareconf`。

而且我猜如果你是通过搜索来到这里，那么问题一定没有解决，不然谁会搜到这么偏僻的一篇博客呢？例如我遇到过 N 次的一个错误如下:

> jni.h: No such file or directory

这个问题可能是因为电脑上默认的 JDK 版本太高了，`R CMD javareconf`无法找到 jni.h 头文件。

除了卸载高版本 JDK 并安装 JDK8之外，网上有很多建议例如修改文件目录、建立文件软链接等等，但是不幸的事这并没有解决我的问题，并且因为混乱的文件管理，导致 java 几近抽风……而且往往安装了高版本 JDK 的用户也对高版本是有需求的，简单的删除虽然简单但是不现实。

## Step 3. `jEnv`- [Manage your Java environment](https://github.com/jenv/jenv)

然而其实解决这个问题也并不是难——不同版本的 JDK 在同一台电脑上是可以共存的，只不过默认的 JDK 只能有一个，单独为 R 配置低版本的 JDK 即可兼顾。

按照 [jEnv](https://github.com/jenv/jenv) 的介绍：

> `jenv` gives you a few critical affordances for using `java` on development machines:
>
> - It lets you switch between `java` versions. This is useful when developing Android applications, which generally require Java 8 for its tools, versus server applications, which use later versions like Java 11.
> - It sets `JAVA_HOME` inside your shell, in a way that can be set globally, local to the current working directory or per shell.

`jEnv`可以在本机安装的不同版本 Java 之间切换，并且可以针对不同的作用范围指定 Java 版本，本示例中主要使用第一个功能。

参考 `jEnv`[官方说明](https://www.jenv.be/)，首先在 Shell 中克隆并加载 jEnv:

```shell
# Clone jEnv git to home directory
$ git clone https://github.com/jenv/jenv.git ~/.jenv

# Set jEnv Path for Bash
$ echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.bash_profile
$ echo 'eval "$(jenv init -)"' >> ~/.bash_profile

# Set jEnv Path for Zsh
$ echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.zshrc
$ echo 'eval "$(jenv init -)"' >> ~/.zshrc
```

> ### Which shell am I using?
>
> 上述设定 jEnv Path 的操作并不是需要都要执行，实际上在进行配置路径之前，大家需要知道自己使用的是什么 Shell，至于 Shell、Bash、Zsh、Terminal、R Console 分别是什么，本文不做进一步讲解，但可以自行搜索，否者很容易混淆。
>
> 可以使用 `echo "$SHELL"` 命令快速的检查当前使用 Shell，例如这里我们看到：
>
> ```shell
> $ echo "$SHELL"
>
> /bin/zsh
> ```
>
> `zsh`关键字即说明我们当前使用的是 zsh

随后将本地已经安装的所有 JDK 路径添加到 `jEnv` 中以供后续管理，例如示例中电脑安装了 JDK8 和 JDK14，那么使用下列命令将两个版本均添加到 `zsh` 中:

```shell
# For macOS, the directory of Java is in
# /Library/Java/JavaVirtualMachines

# Add JDK8 to jEnv
$ jenv add /Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home
openjdk64-1.8.0.292 added
1.8.0.292 added
1.8 added

# Add JDK14 to jEnv
$ jenv add /Library/Java/JavaVirtualMachines/adoptopenjdk-14.jdk/Contents/Home
openjdk64-14.0.2 added
14.0.2 added
14.0 added
14 added

```

Shell 中提示 added 就代表添加成功，使用命令 `jenv versions` 查看已经添加至 `jEnv`中的 JDK 版本，并且该命令可以显示哪个 JDK 被激活：

```shell
$ jenv versions
* system (set by /Users/chenhan/.jenv/version)
  1.8
  1.8.0.292
  14
  14.0
  14.0.2
  openjdk64-1.8.0.292
  openjdk64-14.0.2
```

使用 `jenv global` 切换全局 JDK 版本：

```shell
$ jenv global 1.8
$ jenv versions
  system
* 1.8 (set by /Users/chenhan/.jenv/version)
  1.8.0.292
  14
  14.0
  14.0.2
  openjdk64-1.8.0.292
  openjdk64-14.0.2
```

结果显示 JDK 已经切换至 JDK8 (1.8)。此时再次在 Terminal 中执行 `R CMD javareconf` 应该就可以正确的配置 R 对 Java 的调用。

除了 `jenv global` 控制全局 JDK 版本，还可以通过 `jenv local` 控制当前目录/项目下 JDK 版本，以及通过 `jenv shell` 控制当前 Shell 中 JDK 版本。

通过上述办法，解决了笔者遇到的大多数 `rJava` 遇到的载入包问题。

---
欢迎通过[邮箱](mailto://chenhan28@gmail.com)，[微博](https://weibo.com/womeimingzi11), [Twitter](https://twitter.com/chenhan1992)以及[知乎](https://www.zhihu.com/people/womeimingzi)与我联系。也欢迎关注[我的博客](https://https://blog.washman.top/)。如果能对[我的 Github](https://github.com/womeimingzi11) 感兴趣，就再欢迎不过啦！
