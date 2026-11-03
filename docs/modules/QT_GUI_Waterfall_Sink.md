# QT GUI Waterfall Sink 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / QT GUI Waterfall Sink

## 概览

QT GUI Waterfall Sink 对输入时域样本做加窗 FFT，以颜色表示谱强度，并显示频谱随时间的变化。支持 Float、Complex 和对应的样本消息模式。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Instrumentation（仪器测量） |
| Block ID | `qtgui_waterfall_sink_x` |
| 处理模型 | 连续样本流与消息 |
| 典型位置 | Sink（数据终点） |
| 执行支持 | Python / C++ |

## 何时使用

- 观察稳定单音、扫频和频率漂移。
- 比较随时间变化的频带占用。
- 辅助检查干扰与突发信号。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `0 .. Number of Inputs-1` | 样本流 | float 或 complex | 对应流模式，输入是时域样本 |
| 输入 | `in` | 消息 | f32vector/c32vector 或相应 PDU | 对应 Message 模式 |
| 输入 | `freq` | 消息 | PMT pair，cdr 为 real | Show Msg Ports=Yes 时显示；更新中心频率标注 |
| 输入 | `bw` | 消息 | PMT pair，cdr 为 real | Show Msg Ports=Yes 时显示；更新带宽标注 |
| 输出 | `freq` | 消息 | PMT pair | 频率交互结果，形如 `(freq . 数值)` |

消息控制的是显示坐标；要调谐硬件，需要将交互消息接到支持相应命令的控制端口。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Type** | 枚举 | 选择样本数据类型，必须与相连端口一致 | Float | ✗ |
| **Name** | 字符串 | 设置界面标题或实例名称 |  | ✗ |
| **FFT Size** | 枚举 | 设置 FFT 点数；点数增大会提高频率分辨率并增加计算与延迟 | 1024 | ✗ |
| **Spectrum Width** | 枚举 | 设置显示频谱跨度，单位为 Hz | Full | ✗ |
| **Window Type** | 枚举 | 选择 FFT 窗函数 | Blackman-harris | ✗ |
| **Center Frequency (Hz)** | 浮点数 | 设置显示或设备中心频率，单位为 Hz | 0 | ✓ |
| **Bandwidth (Hz)** | 浮点数 | 设置带宽，单位为 Hz | 32000 | ✓ |
| **Intensity Min** | float | 设置强度色标下限 | -140 | ✓ |
| **Intensity Max** | float | 设置强度色标上限 | 10 | ✓ |
| **Grid** | 枚举 | 控制绘图区网格是否显示 | No | ✗ |
| **Number of Inputs** | 整数 | 设置输入端口数量 | 1 | ✗ |
| **Update Period** | 浮点数 | 设置界面刷新周期，单位为秒 | 0.10 | ✓ |
| **Show Msg Ports** | 枚举 | 控制是否显示运行时控制消息端口 | No | ✗ |
| **GUI Hint** | gui_hint | 设置组件在界面布局中的位置与跨度 |  | ✗ |
| **Legend** | 枚举 | 控制图例是否显示 | Yes | ✗ |
| **Line 1..10 Label** | 字符串 | 设置各路曲线的图例名称 | 各通道预设值 | ✗ |
| **Axis Labels** | 枚举 | 控制坐标轴标签是否显示 | Yes | ✗ |
| **Line 1..10 Color** | 枚举 | 设置各路曲线的显示颜色 | 各通道预设值 | ✗ |
| **Line 1..10 Alpha** | float | 设置各路曲线的透明度 | 各通道预设值 | ✗ |

Line 1..10 为重复的通道样式参数，按当前输入数量使用；各通道初值以面板为准。

## 工作原理

按 FFT Size 收集时域样本，加窗后计算 FFT 和对数谱，将 Intensity Min/Max 对应到颜色范围。Center Frequency 与 Bandwidth 标定频率轴，频点间隔为 Bandwidth/FFT Size。

Update Period 控制界面更新节奏；有效时间分辨能力还取决于 FFT 时间窗、输入速率和调度，不能仅用更新周期保证每个突发都能被捕获。显示单位不是未经校准即可使用的 dBm。

## 快速示例

Complex Signal Source 设置 Sample Rate=32000、Frequency=1000、Amplitude=1，经 Complex Throttle（32000）接本模块。Type=Complex、FFT Size=1024、Center Frequency=0、Bandwidth=32000、Update Period=0.1。

应在约 +1 kHz 处看到持续谱线。将源频率改为 2 kHz 后，较新的频谱位置应发生变化；保留的历史仍反映之前的频率。

## 性能与部署

FFT 点数、输入数量、窗函数和更新频率影响开销。需要完整的突发记录时，另接文件 Sink；调整颜色上下限只改变可见对比度，不改变输入或频谱数据。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 频率坐标不对 | Bandwidth 与采样率不符 | 使用当前处理段实际采样率 |
| 颜色全暗或全亮 | 强度范围不覆盖信号 | 调整 Intensity Min/Max |
| 消息模式无图 | 输入负载类型与 Type 不匹配 | 检查 f32vector/c32vector |
| 短事件没有显示 | 事件短于观察/刷新条件 | 提高观察能力并用文件记录确认 |

## 相关 Block

- [QT GUI Frequency Sink](QT_GUI_Frequency_Sink.md)：观察当前频谱。
- [QT GUI Time Raster Sink](QT_GUI_Time_Raster_Sink.md)：按原始样本排列栅格。
- [File Sink](File_Sink.md)：记录完整数据。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
