---
title: 设备管理器中的 MVSI Card Reader USB Device driver 是什么？如何移除其占用盘符？
author: Han
date: '2020-03-23'
slug: 设备管理器中的-mvsi-card-reader-usb-device-driver-是什么-如何移除其占用盘符.zh-hans
categories:
  - Hardware
tags:
  - Windows驱动
  - 硬件
  - 驱动
---
最近微电脑添置了一块机械硬盘，毕竟在 SSD 价格飞涨的这个时期里，原本计划一步到位 1T NVME 的计划被腰斩至 512 GB。虽然日常的使用中不会遇到任何问题，但是想要保存一些资料依然有捉襟见肘的局促感。

然而当硬盘安装停当，需要设定盘符之时，却发现盘符编号已经被占用了。原本电脑中的 NVME 硬盘仅一个分区 C 盘，按照预想机械硬盘应该紧接着设定为 D 盘。然而设定菜单中新盘符却只能 E 盘起跳，这说明有一个设备占用了 D 盘。

![](https://picgo-1256649726.cos.ap-chengdu.myqcloud.com/Snipaste_2020-03-22_21-27-53.png)

然而实际情况是电脑除了一块 NVME 硬盘并没有其他的存储设备。查看设备管理器的磁盘把驱动器组。发现除了 **NVME 硬盘**（HS-SSD-C2000pro 512G 具体产品是海康 C2000 Pro）、**机械硬盘** （HGST XXXX 日立企业硬盘）、**Hyper-V 虚拟硬盘**（Microsoft 虚拟磁盘，这个与本次的讨论无关）之外，还有一个名为 **MVSI Card Reader USB Device driver** 的设备。

![Snipaste_2020-03-22_21-29-47](https://picgo-1256649726.cos.ap-chengdu.myqcloud.com/Snipaste_2020-03-22_21-29-47.png)

按照设备的名字，大概是一款 USB 读卡器。然而我的机箱本身(TT 启航者 F1 静音版)并没有读卡器，况且我也没有接入其他的 USB 读卡器，莫非是鼠标键盘又抽风了——毕竟曾经遇到过 USB 键鼠插入电脑后无法引导设备的奇葩故障。

不过在尝试插拔键鼠之前，还是决定先把这个 MVSI Card Reader USB Device driver 搜一搜看看是个什么东西。不幸的是搜到的有效结果并不是非常丰富。

![Snipaste_2020-03-22_21-31-24](https://picgo-1256649726.cos.ap-chengdu.myqcloud.com/Snipaste_2020-03-22_21-31-24.png)

虽然第一个条目似乎是设备的驱动下载，但是点进去就有一股浓浓的不能解决问题的感觉。简介基本上是模式化的内容，并没有设备本身相关的内容。截图也是与文无关的样子，虽然提供了驱动程序下载的链接，但是我并不需要下载驱动呀，Windows 已经帮我装好驱动了，故此先将设备放在一边。

![Snipaste_2020-03-22_22-14-33](https://picgo-1256649726.cos.ap-chengdu.myqcloud.com/Snipaste_2020-03-22_22-14-33.png)

第二个搜索条目……日语的？先不看了……

第三个搜索条目，欸，JBL Pebbles？虽然页面内并没有出现任何 MVSI 字样，但是巧合的是，我的电脑上也接入了一台 JBL Pebbles USB 音箱。

此时再扫一眼第二条搜索条目，似乎说到了 uaudio0 字样？虽然对于设备 unix 下的访问名称不熟悉——其实插到我的 MBP 下就能查看了，但是谁让我懒呢——不过 audio 大概是音频设备的相关的吧。耐着性子看作者的 Tweet，似乎在说自己的 JBL Pebbles 插入电脑后也会有一个 Removable SCSI 设备，名字也是  MVSI Card Reader USB Device driver。

![Snipaste_2020-03-22_21-30-53](https://picgo-1256649726.cos.ap-chengdu.myqcloud.com/Snipaste_2020-03-22_21-30-53.png)

考虑到巧合不会同时出现两次（无来源，我现编的），果断拔下 JBL Pebbles，设备管理器中的  MVSI Card Reader USB Device driver 设备消失，在磁盘管理器中也能将机械硬盘设置成为 D 盘了，done！

![Snipaste_2020-03-22_22-17-07](https://picgo-1256649726.cos.ap-chengdu.myqcloud.com/Snipaste_2020-03-22_22-17-07.png)

事后回想起来，猜测是因为采用 USB 连接电脑的 JBL Pebbles 音箱会采用 USB DAC 的方式来实现工作。但巧合的是这台 USB DAC 还预留了读卡器的接口，虽然 JBL Pebbles 并没有读卡的功能。

不过虽然盘符的问题已经解决了，但是其实还有一个小瑕疵，那就是 Windows Traybar 里面会一直有一个快速移除设备的图标，并且总有一个省略号设备，且无法点击。

![Snipaste_2020-03-22_22-09-17](https://picgo-1256649726.cos.ap-chengdu.myqcloud.com/Snipaste_2020-03-22_22-09-17.png)

解决方法也很简单，只要从设备管理器中选中 MVSI Card Reader USB Device driver 然后将其禁用即可。目前没有发现副作用。

![Snipaste_2020-03-22_22-17-07](https://picgo-1256649726.cos.ap-chengdu.myqcloud.com/Snipaste_2020-03-22_22-17-07.png)
