# Changelog

<details>
<summary>v1.8.1030</summary>

### 功能

-   添加弹幕图片支持
-   添加抖音账号支持
-   修复抖音分类，搜索等功能
-   关注刷新优化 by [@SlotSun](https://github.com/SlotSun)
-   关注、标签功能 UI 调整 by [@SlotSun](https://github.com/SlotSun)
-   生成 AcSignature
    修复二维码失效时自动重载

### 修复

-   自动全屏 [#10](https://github.com/GH4NG/dart_simple_live/issues/10)
-   修复抖音播放清晰度切换问题
-   恢复后台后弹幕消失
-   唤醒锁功能 [#3](https://github.com/GH4NG/dart_simple_live/issues/3)

</details>

<details>
<summary>v1.8.0911</summary>

### 功能

-   重构播放器，从 media_kit 迁移到 fvp
-   播放器支持全屏模式自动隐藏鼠标指针
-   支持刷新当前关注用户信息 by [@SlotSun](https://github.com/SlotSun)
-   记忆窗口大小功能 by [@SlotSun](https://github.com/SlotSun)
-   支持设置播放器中 SC 显示隐藏 by [@xiaoyaocz](https://github.com/xiaoyaocz)

### 修复

-   修复部分标签功能的问题 by [@SlotSun](https://github.com/SlotSun)
-   修复抖音解析 & abogus 算法

</details>

<details>
<summary>v1.8.0822</summary>

### 修复

-   修复从上游迁移时关注列表导入失败的问题
-   修复 iOS 平台调用 JS 时可能导致的闪退

### 功能

-   抖音 / 斗鱼解析逻辑更新：移除对服务器 API 的依赖
-   调整部分页面布局与样式
-   更新依赖包至最新版本

</details>

<details>
<summary>v1.8.6</summary>

### 修复

-   修复虎牙播放中断 [#723](https://github.com/xiaoyaocz/dart_simple_live/issues/723) by [@SlotSun](https://github.com/SlotSun)
-   修复哔哩哔哩加载失败
-   修复导出配置错误 by [@CNOCM](https://github.com/CNOCM)

### 功能

-   复制未播放直播流 [#728](https://github.com/xiaoyaocz/dart_simple_live/issues/728) by [@SlotSun](https://github.com/SlotSun)
-   支持解析斗鱼 topic 链接 by [@SlotSun](https://github.com/SlotSun)
-   支持自定义音频输出驱动 by [@ybhgl](https://github.com/ybhgl)

</details>

<details>
<summary>v1.8.3</summary>

### 修复

-   修复虎牙播放中断 [#700](https://github.com/xiaoyaocz/dart_simple_live/issues/700) by [@SlotSun](https://github.com/SlotSun)
-   修复 PC 画面中间出现黑色椭圆点 [#695](https://github.com/xiaoyaocz/dart_simple_live/issues/695) by [@SlotSun](https://github.com/SlotSun)

### 功能

-   支持直接复制直链 [#658](https://github.com/xiaoyaocz/dart_simple_live/issues/658) by [@venkate123](https://github.com/venkate123)

</details>

<details>
<summary>v1.8.1</summary>

### 修复

-   屏蔽斗鱼机器人弹幕
-   修复哔哩哔哩推荐、分类加载失败

### 优化

-   回滚 Flutter 版本到 3.22

</details>

<details>
<summary>v1.7.15</summary>

### 修复

-   修复抖音和虎牙问题
-   修复部分 bug

### 功能

-   使用 flutter_js 获取 sign 替代 API
-   确保 Android 和 Windows 可用

</details>

<details>
<summary>v1.7.14</summary>

### 修复

-   修复部分 bug

</details>

<details>
<summary>v1.7.13</summary>

### 修复

-   修复哔哩哔哩风控问题
-   修复部分 bug

</details>

<details>
<summary>v1.7.12</summary>

### 修复

-   修复虎牙断流
-   修复部分 bug

### 优化

-   迁移弹幕库，优化弹幕性能

</details>

<details>
<summary>v1.7.11</summary>

### 修复

-   屏蔽斗鱼机器人弹幕
-   修复哔哩哔哩推荐、分类加载失败

### 优化

-   升级 Flutter 版本到 3.29.x
-   优化标签功能

</details>

<details>
<summary>v1.7.10</summary>

### 优化

-   优化一些细节

</details>

<details>
<summary>v1.7.8</summary>

### 修复

-   修复虎牙断流 ([#594](https://github.com/xiaoyaocz/dart_simple_live/issues/594))

</details>

<details>
<summary>v1.7.7</summary>

### 修复

-   修复哔哩哔哩分类加载失败 [#630](https://github.com/xiaoyaocz/dart_simple_live/issues/630)
-   修复屏蔽词列表同步失败 [#619](https://github.com/xiaoyaocz/dart_simple_live/issues/619) by [@SlotSun](https://github.com/SlotSun)
-   修复虎牙断流 [#585](https://github.com/xiaoyaocz/dart_simple_live/issues/585) by [@SlotSun](https://github.com/SlotSun)

### 功能

-   支持 WebDAV 同步 [#617](https://github.com/xiaoyaocz/dart_simple_live/issues/617) by [@SlotSun](https://github.com/SlotSun)

</details>

<details>
<summary>v1.7.6</summary>

### 修复

-   修复虎牙播放中断 [#585](https://github.com/xiaoyaocz/dart_simple_live/issues/585)

</details>

<details>
<summary>v1.7.5</summary>

### 修复

-   修复虎牙一起看播放中断 [#543](https://github.com/xiaoyaocz/dart_simple_live/issues/543)

</details>

<details>
<summary>v1.7.4</summary>

### 修复

-   修复虎牙一起看播放中断 [#543](https://github.com/xiaoyaocz/dart_simple_live/issues/543)
-   播放中断后取消保持亮屏 [#541](https://github.com/xiaoyaocz/dart_simple_live/issues/541)

### 优化

-   强制使用 HTTPS 链接 [#538](https://github.com/xiaoyaocz/dart_simple_live/issues/538)
-   Windows 字体使用微软雅黑 [#535](https://github.com/xiaoyaocz/dart_simple_live/issues/535)

</details>

<details>
<summary>v1.7.3 / v1.7.2</summary>

### 修复

-   修复斗鱼分类无法加载 [#485](https://github.com/xiaoyaocz/dart_simple_live/issues/485)
-   修复哔哩哔哩直播加载失败 [#489](https://github.com/xiaoyaocz/dart_simple_live/issues/489)

### 功能

-   支持远程同步数据
-   支持导入导出应用设置
-   支持手动输入 Cookie 登录哔哩哔哩 [#463](https://github.com/xiaoyaocz/dart_simple_live/issues/463)
-   支持定时自动更新关注列表 [#453](https://github.com/xiaoyaocz/dart_simple_live/issues/453)

</details>

<details>
<summary>v1.6.5</summary>

### 修复

-   修复抖音弹幕连接失败问题 [#458](https://github.com/xiaoyaocz/dart_simple_live/issues/458)
-   修复弹幕不消失问题 [#454](https://github.com/xiaoyaocz/dart_simple_live/issues/454)

### 功能

-   恢复抖音直播间搜索

</details>

<details>
<summary>v1.6.3</summary>

### 修复

-   修复抖音无法读取直播状态 [#431](https://github.com/xiaoyaocz/dart_simple_live/issues/431)
-   修复抖音无法读取原画 [#429](https://github.com/xiaoyaocz/dart_simple_live/issues/429)

### 优化

-   优化直播状态读取
-   斗鱼默认不使用 PCDN 链接

</details>

<details>
<summary>v1.6.0</summary>

### 修复

-   修复 MacOS 打开同步失败 [#351](https://github.com/xiaoyaocz/dart_simple_live/issues/351)
-   修复 Windows 返回时亮度调节至最高 [#332](https://github.com/xiaoyaocz/dart_simple_live/issues/332)
-   修复虎牙分类加载失败 [#366](https://github.com/xiaoyaocz/dart_simple_live/issues/366)
-   修复虎牙无法播放问题 [#409](https://github.com/xiaoyaocz/dart_simple_live/issues/409)
-   修复链接跳转时虚拟导航条显示错误 [#373](https://github.com/xiaoyaocz/dart_simple_live/issues/373)
-   修复播放器锁定时依旧触发长按事件

### 功能

-   支持调整弹幕字重 [#372](https://github.com/xiaoyaocz/dart_simple_live/issues/372)
-   支持日志记录
-   支持抖音手机端分享链接解析 [#376](https://github.com/xiaoyaocz/dart_simple_live/issues/376)
-   支持复制直播间链接
-   支持滑动删除历史记录 [#231](https://github.com/xiaoyaocz/dart_simple_live/issues/231)
-   支持自定义视频输出驱动
-   PC 页面增加刷新按钮

### 优化

-   优化桌面小窗播放
-   优化关注列表加载
-   优化直播间加载错误的处理
-   统一全平台图标，安卓支持主题图标 [#140](https://github.com/xiaoyaocz/dart_simple_live/issues/140) [#112](https://github.com/xiaoyaocz/dart_simple_live/issues/112)
-   尝试使用 WebView 实现抖音搜索 [#379](https://github.com/xiaoyaocz/dart_simple_live/issues/379)

</details>

<details>
<summary>v1.5.x</summary>

### 修复

-   修复虎牙播放中断问题 [#339](https://github.com/xiaoyaocz/dart_simple_live/issues/339) by [@lemonfog](https://github.com/lemonfog)

### 功能

-   支持多端数据同步
-   Linux 使用 mimalloc 防止内存泄漏 [#328](https://github.com/xiaoyaocz/dart_simple_live/issues/328) by [@madoka773](https://github.com/madoka773)

</details>

<details>
<summary>v1.4.x</summary>

### 修复

-   修复虎牙播放中断问题 [#317](https://github.com/xiaoyaocz/dart_simple_live/issues/317)
-   修复抖音内容加载失败 [#285](https://github.com/xiaoyaocz/dart_simple_live/issues/285)
-   修复音量拖动调节卡顿 [#92](https://github.com/xiaoyaocz/dart_simple_live/issues/92) (#294 by [@abcghy](https://github.com/abcghy))
-   非横屏隐藏首页左侧分割线 [#235](https://github.com/xiaoyaocz/dart_simple_live/issues/235)
-   修复抖音 Web 链接跳转错误 [#248](https://github.com/xiaoyaocz/dart_simple_live/issues/248)
-   修复虎牙无法观看问题 [#220](https://github.com/xiaoyaocz/dart_simple_live/issues/220)
-   修复手势提示不消失 [#223](https://github.com/xiaoyaocz/dart_simple_live/issues/223)
-   刷新直播间不清空消息列表 [#225](https://github.com/xiaoyaocz/dart_simple_live/issues/225)

### 功能

-   iOS 放开后台播放设置
-   弹幕支持使用正则屏蔽 [#283](https://github.com/xiaoyaocz/dart_simple_live/issues/283) (#295 by [@abcghy](https://github.com/abcghy))
-   定时关闭建议记忆上次设定的时长 [#278](https://github.com/xiaoyaocz/dart_simple_live/issues/278) (#296 by [@abcghy](https://github.com/abcghy))
-   增加不再提示登录选项 [#219](https://github.com/xiaoyaocz/dart_simple_live/issues/219)
-   增加数据网络下清晰度设置 [#237](https://github.com/xiaoyaocz/dart_simple_live/issues/237)
-   增加进入后台自动暂停选项 [#240](https://github.com/xiaoyaocz/dart_simple_live/issues/240)
-   进入后台时不添加弹幕 [#230](https://github.com/xiaoyaocz/dart_simple_live/issues/230)
-   增加动态取色/主题色选择 [#213](https://github.com/xiaoyaocz/dart_simple_live/issues/213) by [@AprDeci](https://github.com/AprDeci)

### 优化（桌面）

-   增加加载更多按钮 [#228](https://github.com/xiaoyaocz/dart_simple_live/issues/228)
-   鼠标侧键优先退出全屏
-   esc 退出全屏播放 [#197](https://github.com/xiaoyaocz/dart_simple_live/issues/197) by [@AprDeci](https://github.com/AprDeci)
-   添加桌面端鼠标滑动操控 [#197](https://github.com/xiaoyaocz/dart_simple_live/issues/197) by [@AprDeci](https://github.com/AprDeci)
-   支持音量调节 [#147](https://github.com/xiaoyaocz/dart_simple_live/issues/147) [#204](https://github.com/xiaoyaocz/dart_simple_live/issues/204) by [@AprDeci](https://github.com/AprDeci)
-   桌面支持小窗 [#204](https://github.com/xiaoyaocz/dart_simple_live/issues/204) by [@AprDeci](https://github.com/AprDeci)

</details>

<details>
<summary>v1.3.x</summary>

### 修复

-   修复直播间黑屏 [#125](https://github.com/xiaoyaocz/dart_simple_live/issues/125)
-   修复抖音直播问题 [#121](https://github.com/xiaoyaocz/dart_simple_live/issues/121)

### 功能

-   支持直播间定时关闭 [#124](https://github.com/xiaoyaocz/dart_simple_live/issues/124)
-   支持主页与平台自定义排序 [#16](https://github.com/xiaoyaocz/dart_simple_live/issues/16), [#76](https://github.com/xiaoyaocz/dart_simple_live/issues/76)
-   支持跳转至原 APP 中打开直播间 [#118](https://github.com/xiaoyaocz/dart_simple_live/issues/118)
-   斗鱼增加录播判断 [#6](https://github.com/xiaoyaocz/dart_simple_live/issues/6), [#103](https://github.com/xiaoyaocz/dart_simple_live/issues/103)
-   播放失败尝试自动重连
-   支持全屏播放器截图
-   优化哔哩哔哩直播弹幕获取

### 优化

-   优化播放器 [#78](https://github.com/xiaoyaocz/dart_simple_live/issues/78), [#113](https://github.com/xiaoyaocz/dart_simple_live/issues/113)
-   支持画面尺寸调整 [#61](https://github.com/xiaoyaocz/dart_simple_live/issues/61)
-   支持锁定播放器 [#53](https://github.com/xiaoyaocz/dart_simple_live/issues/53)
-   取消关注增加提示框 [#120](https://github.com/xiaoyaocz/dart_simple_live/issues/120)

</details>

<details>
<summary>v1.2.x</summary>

### 修复

-   修复斗鱼无法播放 [#98](https://github.com/xiaoyaocz/dart_simple_live/issues/98)
-   修复进入后台自动暂停 [#89](https://github.com/xiaoyaocz/dart_simple_live/issues/89), [#88](https://github.com/xiaoyaocz/dart_simple_live/issues/88), [#85](https://github.com/xiaoyaocz/dart_simple_live/issues/85), [#77](https://github.com/xiaoyaocz/dart_simple_live/issues/77)
-   修复弹幕描边设置不生效 [#81](https://github.com/xiaoyaocz/dart_simple_live/issues/81)
-   修复虎牙直播播放问题 [#71](https://github.com/xiaoyaocz/dart_simple_live/issues/71)
-   修复哔哩哔哩部分直播间无法观看 [#59](https://github.com/xiaoyaocz/dart_simple_live/issues/59)
-   修复弹幕默认开关设置无效问题 [#65](https://github.com/xiaoyaocz/dart_simple_live/issues/65)

### 功能

-   启用 v1+v2 签名 [#96](https://github.com/xiaoyaocz/dart_simple_live/issues/96)
-   点击底部导航栏返回顶部/刷新 [#84](https://github.com/xiaoyaocz/dart_simple_live/issues/84), [#93](https://github.com/xiaoyaocz/dart_simple_live/issues/93)
-   播放器增加兼容模式
-   修改虎牙直播间标题获取 [#48](https://github.com/xiaoyaocz/dart_simple_live/issues/48)
-   增加进入直播间自动全屏选项 [#41](https://github.com/xiaoyaocz/dart_simple_live/issues/41)
-   增加弹幕关键词屏蔽功能 [#70](https://github.com/xiaoyaocz/dart_simple_live/issues/70)
-   增加双击全屏功能 [#56](https://github.com/xiaoyaocz/dart_simple_live/issues/56)
-   关注列表支持导入导出 [#19](https://github.com/xiaoyaocz/dart_simple_live/issues/19)

</details>

<details>
<summary>v1.1.x</summary>

### 功能

-   播放器由 flutter_vlc_player 变更为 media_kit
-   优化搜索，区分主播与直播间
-   优化播放页面
-   支持抖音直播平台
-   新增定时关闭功能

### 修复

-   修复一些 BUG

</details>
