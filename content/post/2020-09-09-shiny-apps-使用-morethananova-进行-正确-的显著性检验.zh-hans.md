---
title: 'Shiny apps: 使用 moreThanANOVA 进行「正确」的显著性检验'
author: Han
date: '2020-06-09'
slug: shiny-apps-使用-morethananova-进行-正确-的显著性检验.zh-hans
categories:
  - Shiny
tags:
  - R
  - Shiny
  - Analysis
  - ANOVA
---

## TL:DR
使用 [moreThanANOVA](https://hanchen.shinyapps.io/moreThanANOVA/) 可以自动选择适当的方法显著性检验并输出多重比较的图表（如题图）

<!-- more -->

## ANOVA 不是万金油
显著性检验可以说是自然科学领域中最常见的操作，毕竟探究处理间是否有差异、区域间特征异同是后续探索以及假设的第一步。

然而，当我们阅读文献和报告之时不难发现，单因素方差分析 ANOVA 似乎是被用来进行显著性检验的唯一方法，但凡展示显著性，如果没什么意外必然是通过 ANOVA 做出的结果。而之所以出现这种状况，除了数据确实需要 ANOVA 检验，「其他人都用这个方法」也是重要因素。然而，用的人多的方法就一定是对的方法吗？

**当然不是**，使用 ANOVA 检验数据最重要的前提便是假设数据符合正态分布。

虽然通常来说，当数据的量足够大的情况下，往往会呈现出正态分布，但当具体到某次研究中，结果却并不见得如此。当然我们还有数据转换这类操作，可以试图让各种数据尽可能的达到符合正态分布，然而就像不是所有的付出都有回报一样，也不是所有的数据转换都能达到正态期望，亦或者通过复杂的转换数据也许能够实现正态分布，然而复杂的转换本身又会令解释工作变得复杂。

当然，即便数据分布不符合正态分布，使用 ANOVA 进行显著性检验也会得到结果，甚至是你喜欢的结果。然而使用错误的方法得到的「美好」结果依然是错误的。

## 不止是 ANOVA
对于无法使用 ANOVA 进行显著性检验的数据，我们可以退而求其次选择**非参数检验** non-parametric tests，其中最常见的便是秩检验 Rank test。对于只有两组/处理的数据，通常使用 **Mann–Whitney U test**或**Wilcox test**，对于有三组/处理及以上的数据可以使用 **Kruskal-Wallis test**.

此外，根据组间样本数量异同还分为秩和检验 Rank Sum Test 和秩序检验 Signed Rank Test，其中的细节此处不再详述，可以参考如下文章：
1. [Unpaired Two-Samples Wilcoxon Test in R](http://www.sthda.com/english/wiki/unpaired-two-samples-wilcoxon-test-in-r)
2. [wilcox.test](https://www.rdocumentation.org/packages/stats/versions/3.6.2/topics/wilcox.test)

虽然非参数检验其数据敏感度与 ANOVA 这类参数检验数据敏感度相比较低，然而正确的分析方法依然是所有讨论的前提。

## 正确的流程
因此，一次正确的显著性检验的流程应当为：

1. 输入数据
2. 数据分布探索
3. 数据转换（可选）
4. 检验方法确定
5. 显著性检验
6. 多重比较

虽然这些步骤每一步使用 R 实现都并不复杂，然而当需要比较组间 N 个变量的差异时，即便采用了 map-reduce 模式处理，依然需要大量的工作，更何况如何将 R console 中打印的结果整理为可以编辑的表格以及将结果制作成可供出版的示意图，也会需要更多额外的工作。

基于此，笔者使用 Shiny 将这套流程打包成名为 [moreThanANOVA 的 Shiny App ](https://hanchen.shinyapps.io/moreThanANOVA) 托管于 Shinyapps.io.

## It just works
### Data Viewer
在 Data Viewer 页面，通过 DT 包实现了展示输入数据的功能，当没有上传数据之时，可以通过 Data Viewer 查看 moreThanANOVA 内置的示例数据（*数据本身无意义，仅供演示之用途*）。

![Data Viewer](https://picgo-1256649726.cos.ap-chengdu.myqcloud.com/Data_Viewer_2)
### Distribution Determine
在 Distribution Determine 页面，moreThanANOVA 会检验所有变量在不同组中的分布类型，目前仅分为 normal 和 skewed，然而对于双峰分布等其他分布类型，非参数检验也依然适用，因此之后的分析结果依然可靠。

![](https://picgo-1256649726.cos.ap-chengdu.myqcloud.com/data_dist)

当同一变量在不同组中的分布类型不相同时，moreThanANOVA 会采用非参数检验进行之后的分析，同时在 Density Plot 中绘制数据分布密度图。

![](https://picgo-1256649726.cos.ap-chengdu.myqcloud.com/density_plot)

### Comparisons
在 Comparisons 页面，首先 moreThanANOVA 会通过在前期步骤中确定的检验方法，进行组间显著性检验。同时会将均值、标准差、中位数以及四分位距 Interquartile range, IQR 输出为可下载的可交互表格。

![](https://picgo-1256649726.cos.ap-chengdu.myqcloud.com/compare_table)

最后，moreThanANOVA 还会生成基于多重检验的图形，目前可以自定义图中 X/Y 轴以及题头标签，显示相关性级别、相关性的表示方法（p 或者 *）、多组图片之间的排列方式以及下载图片的宽、高。

####为何采用 PDF 输出图形？
使用 PDF 可以输出矢量图，能够有效避免 DPI 造成的清晰度问题，同时拥有极小的体积以及不错的兼容性。

![](https://picgo-1256649726.cos.ap-chengdu.myqcloud.com/post_hoc_figure.png)

目前 moreThanANOVA 托管于 Rstudio 旗下 Shinyapps.io 网站，源代码托管于 [GitHub](https://github.com/womeimingzi11/moreThanANOVA)。服务运行过程中不会永久保存用户数据，数据有效期仅保留至网页关闭前。

同时如果对于数据高度敏感，也可以考虑将[ fork 项目](https://github.com/womeimingzi11/moreThanANOVA/fork/) 或下载至本地后，手动运行 app.R 在本地电脑执行操作。

如有任何使用中的疑问、功能上的建议与意见，欢迎与[我联系](mailto://chenhan28@gmail.com)。当然也欢迎 [Star](https://github.com/womeimingzi11/moreThanANOVA/star/) 以及进行任何提交。