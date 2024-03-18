# flutter_kline

<img src="https://raw.githubusercontent.com/BrinedFish0222/flutter_kline/master/resources/example_1.jpg" width="300" /><img src="https://raw.githubusercontent.com/BrinedFish0222/flutter_kline/master/resources/example_2.jpg" width="300" />



之前在一家公司负责股票软件的开发，发现 flutter 关于股票K线图这方面的资源都是很老旧的项目，拿来使用的过程中也发现了一些需要进行改善的地方，所以有了这个开源项目，**flutter_kline 只是给你提供一个实现接近通达信K线图级别的思路，它只能接近，无法完全媲美**。

:warning:我只有半年的app开发经验，是一个萌新，请容忍我的烂代码:sweat_smile::sweat_smile::sweat_smile:。

:warning: 目前 flutter_kline 更多是一个画K线图的思路，不是完整可以直接商业使用的版本。

如果这个项目对你有启发，请一定要给个 :star: :star: :star:

如果你需要股票指标引擎的思路，可以参考我另一个开源项目：[BrinedFish0222/stock_indicator_engine: 股票指标引擎 (github.com)](https://github.com/BrinedFish0222/stock_indicator_engine)





# 为什么使用 flutter_kline

:snowflake: flutter_kline 是一个没有任何第三方插件包的项目，它不会和你项目原本指定的第三方插件版本产生冲突，降低集成的成本，它是纯净的。

:fallen_leaf: flutter_kline 的K线图底层是由一个个单独的矩形图、线图、柱图合并而成，你可以针对不同情况进行性能优化。例如：拖动十字线时不应该刷新K线图。

:four_leaf_clover: 如果你使用的K线图是主图和副图是一张图的，那你或许有点击K线图信息栏更换指标识别精准度问题，flutter_kline 的拆分思想解决了这个问题，一切都是由散件组合而成，你能精准的点击到它，更换你的指标。

:frog: flutter_kline 解决了其它老项目在K线图外层套滑动组件（例如：ListView）引发的手势冲突问题。

:blue_heart: 你可以增加任意数量的副图。

# 快速开始

flutter version 3.10.5

直接[下载 apk 体验](https://github.com/BrinedFish0222/flutter_kline/releases)。

`lib/main.dart` 启动即可。

`example_network/lib/main.dart` 提供了一个分时图接入 websocket 实时刷新的示例，正如前面所说 flutter_kline 的拆分思想，你可以根据你项目的不同情况进行特定优化。

