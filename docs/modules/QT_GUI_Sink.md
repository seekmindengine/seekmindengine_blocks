# QT GUI Sink 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / QT GUI Sink

## 概览

QT GUI Sink 模块将频谱图、瀑布图、时域图和星座图集成在一个 Qt 窗口中。它适合在调试阶段快速观察信号的多个视角，不需要同时拖入 Frequency Sink、Waterfall Sink、Time Sink 和 Constellation Sink。

这个模块偏向“综合观察”。如果需要精细控制单个图的坐标、曲线、触发、颜色或多通道显示，通常使用单独的 QT GUI Frequency/Time/Waterfall/Constellation Sink 更合适。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Instrumentation（仪器测量） |
| Block ID | `qtgui_sink_x` |
| 处理模型 | 连续样本流与消息 |
| 典型位置 | Sink（数据终点） |
| 执行支持 | Python / C++ |

## 何时使用

1. **综合信号监视**  
   在一个窗口里同时查看时域、频域、瀑布和星座

2. **接收机调试**  
   快速判断频偏、带宽、幅度、星座收敛等情况

3. **调制链路验证**  
   观察 PSK/GMSK 等调制信号的时域和频域表现

4. **教学和演示**  
   用较少模块展示多种信号视图

5. **原型阶段诊断**  
   在正式界面设计前快速定位问题

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | 由数据类型参数决定 | 连续样本流端口 |
| 输入 | `freq` | 消息 | `按消息格式` | 离散消息端口；可选 |
| 输出 | `freq` | 消息 | `按消息格式` | 离散消息端口；可选 |

> 显示参数不会改变上游数据。高采样率场景优先降低刷新频率或显示点数，避免界面渲染成为实时链路瓶颈。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---------|------|------|--------|
| **Type** | 枚举 | 输入类型：complex 或 float | float |
| **Name** | 字符串 | 窗口标题 | "" |
| **FFT Size** | 枚举 | FFT 点数，32 到 32768 | 1024 |
| **Window Type** | 枚举 | FFT 窗函数 | Blackman-harris |
| **Center Frequency (Hz)** | 浮点数 | 频率显示中心 | 0 |
| **Bandwidth (Hz)** | 浮点数 | 显示带宽，通常填采样率 | 32000 |
| **Update Rate** | 浮点数 | 每秒刷新次数 | 10 |
| **Show RF Freq** | 枚举 | 是否显示射频频率 | No |
| **Plot Frequency** | 枚举 | 是否显示频谱图 | On |
| **Plot Waterfall** | 枚举 | 是否显示瀑布图 | On |
| **Plot Time** | 枚举 | 是否显示时域图 | On |
| **Plot Const** | 枚举 | 是否显示星座图 | On |
| **Show Msg Ports** | 枚举 | 是否显示 freq 消息端口 | No |
| **GUI Hint** | gui_hint | Qt 布局位置提示 | - |

## 参数说明

**1. Type（输入类型）**
- complex：用于 IQ 基带信号、调制信号、频域复数数据
- float：用于音频、实数传感器数据、幅度或功率数据
- 类型必须与上游输出端口一致

**2. FFT Size（FFT 点数）**
- 控制频谱和瀑布图的频率分辨率
- 点数越大，频率分辨率越高，但刷新和计算开销也增加
- 常用值：1024、2048、4096

**3. Window Type（窗函数）**
- 影响频谱泄漏和主瓣宽度
- Blackman-harris 旁瓣抑制较好，适合观察弱信号
- Hamming/Hann 常用于通用频谱观察
- Rectangular 频率分辨率直观但泄漏较明显

**4. Center Frequency（中心频率）**
- 只影响频率轴标注，不改变信号内容
- 对基带仿真可设为 0
- 对 SDR 接收可设为硬件调谐频率，便于读出真实频率

**5. Bandwidth（带宽）**
- 通常应填写输入采样率
- 决定频率轴范围和时间轴标定
- 如果填错，图形仍会显示，但坐标含义错误

**6. Update Rate（刷新率）**
- 单位是每秒刷新次数
- 值越大界面越实时，但 CPU/GPU 开销越高
- GUI 卡顿时可降低该值

**7. Plot 开关**
- 可按需要关闭某些视图
- 关闭不用的视图可以降低界面开销
- 对 float 输入，星座图的意义通常不如 complex 输入直观

**8. Show Msg Ports（显示消息端口）**
- 开启后显示 freq 消息输入/输出端口
- 可用于运行时更新或联动频率显示

**9. GUI Hint（布局提示）**
- 用于指定控件在 Qt GUI 中的位置
- 形式通常类似 `[tab_id@tab_index]: [row, col, row_span, col_span]`
- 不熟悉布局时可保持默认

## 工作原理

```
输入 stream
   ├→ Time Plot
   ├→ FFT → Frequency Plot
   ├→ FFT → Waterfall Plot
   └→ Constellation Plot
```

QT GUI Sink 不改变输入数据，只复制和缓存数据用于显示。

## 快速示例

**示例 1：观察仿真正弦信号**

```
[Signal Source] → [Throttle] → [QT GUI Sink]
```

配置参数：
- Type: float 或 complex，取决于 Signal Source 输出
- Bandwidth: 与采样率一致
- FFT Size: 1024

**示例 2：SDR 接收监视**

```
[UHD: USRP Source] → [Low Pass Filter] → [QT GUI Sink]
```

配置参数：
- Type: complex
- Center Frequency: USRP 调谐频率
- Bandwidth: 滤波后或输入采样率
- Show RF Freq: Yes

**示例 3：调制信号星座观察**

```
[PSK Mod] → [QT GUI Sink]
```

开启 Plot Const，可以同时观察星座点、频谱和时域包络。

## 什么时候使用本模块

适合：
- 快速调试
- 教学演示
- 单路信号的综合观察
- 不确定问题出在时域、频域还是星座时

不太适合：
- 多路曲线精细对比
- 需要复杂触发和坐标控制
- 长时间高采样率监控
- 正式产品界面中的精细布局

## 性能与部署

1. **FFT Size 和刷新率影响 CPU**  
   点数越大、Update Rate 越高，计算和绘图开销越大。

2. **多个视图同时开启会增加开销**  
   只保留需要的 Plot 可以改善性能。

3. **GUI 不应该承担限速职责**  
   纯软件源仍建议使用 Throttle；硬件源由硬件采样率控制。

4. **高采样率下显示只是抽样观察**  
   GUI 无法把每个样本都逐点绘制出来，显示结果用于监视和诊断。

## 故障排查

**Q1: Bandwidth 应该填什么？**  
A: 通常填输入信号采样率。若填错，频率轴会错。

**Q2: Center Frequency 会改变信号频率吗？**  
A: 不会。它只影响频率坐标显示。

**Q3: 为什么 GUI 很卡？**  
A: 降低 FFT Size、Update Rate，关闭不需要的 Plot，或降低输入采样率。

**Q4: float 输入能看星座图吗？**  
A: 可以显示，但星座图主要用于 complex 调制信号。float 信号更适合 Time/Frequency 视图。

**Q5: 和 QT GUI Frequency Sink 有什么区别？**  
A: QT GUI Sink 是综合显示；Frequency Sink 专注频谱，参数和显示控制更细。

## 典型应用场景

**接收机总览：**

```
[Source] → [Filter] → [QT GUI Sink]
```

**调制器检查：**

```
[Random Source] → [PSK Mod] → [QT GUI Sink]
```

**滤波效果观察：**

```
[Noise + Signal] → [Low Pass Filter] → [QT GUI Sink]
```

## 相关 Block

- [QT GUI Frequency Sink](QT_GUI_Frequency_Sink.md)：频谱显示
- [QT GUI Time Sink](QT_GUI_Time_Sink.md)：时域显示
- [QT GUI Waterfall Sink](QT_GUI_Waterfall_Sink.md)：瀑布图显示
- [QT GUI Constellation Sink](QT_GUI_Constellation_Sink.md)：星座图显示

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
