# QT GUI Histogram Sink 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / QT GUI Histogram Sink

## 概览

QT GUI Histogram Sink 对 Float 样本按幅值区间分箱并显示计数，支持样本流和 Float Message 两种输入模式。它适合观察幅度分布、噪声分布和异常值。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Instrumentation（仪器测量） |
| Block ID | `qtgui_histogram_sink_x` |
| 处理模型 | 连续样本流 |
| 典型位置 | Sink（数据终点） |
| 执行支持 | Python |

## 何时使用

- 检查高斯或均匀噪声的幅度分布。
- 比较多路实数数据的分布。
- 对复数信号先计算幅度，再观察幅度直方图。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `0 .. Number of Inputs-1` | 样本流 | float | Type=Float 时使用 |
| 输入 | `in` | 消息 | f32vector 或含 f32vector 的 PDU | Type=Float Message 时使用 |

没有 Complex 输入模式；复数幅度需先经过 Complex to Mag。显示不会输出计数流。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Type** | 枚举 | 选择样本数据类型，必须与相连端口一致 | Float | ✗ |
| **Name** | 字符串 | 设置界面标题或实例名称 |  | ✗ |
| **Number of Points** | 整数 | 设置每次显示或计算的点数 | 1024 | ✗ |
| **Number of Bins** | 整数 | 设置直方图分箱数量 | 100 | ✓ |
| **Grid** | 枚举 | 控制绘图区网格是否显示 | No | ✗ |
| **Autoscale** | 枚举 | 控制坐标范围是否根据输入数据自动调整 | Yes | ✗ |
| **Accumulate** | 枚举 | 控制是否跨刷新周期累计统计结果 | No | ✗ |
| **Min x-axis** | 浮点数 | 设置 X 轴显示下限 | -1 | ✓ |
| **Max x-axis** | 浮点数 | 设置 X 轴显示上限 | 1 | ✓ |
| **Number of Inputs** | 整数 | 设置输入端口数量 | 1 | ✗ |
| **Update Period** | float | 设置界面刷新周期，单位为秒 | 0.10 | ✓ |
| **GUI Hint** | gui_hint | 设置组件在界面布局中的位置与跨度 |  | ✗ |
| **Legend** | 枚举 | 控制图例是否显示 | Yes | ✗ |
| **Axis Labels** | 枚举 | 控制坐标轴标签是否显示 | Yes | ✗ |
| **Line 1..10 Label** | 字符串 | 设置各路曲线的图例名称 | 各通道预设值 | ✗ |
| **Line 1..10 Width** | 整数 | 设置各路曲线的线宽 | 1 | ✗ |
| **Line 1..10 Color** | 枚举 | 设置各路曲线的显示颜色 | 各通道预设值 | ✗ |
| **Line 1..10 Style** | 枚举 | 设置各路曲线的线型 |  | ✗ |
| **Line 1..10 Marker** | 枚举 | 设置各路曲线的数据点标记 |  | ✗ |
| **Line 1..10 Alpha** | float | 设置各路曲线的透明度 | 各通道预设值 | ✗ |

Line 1..10 为重复的通道样式参数，按当前输入数量使用；各通道初值以面板为准。

## 工作原理

将 Min x-axis 到 Max x-axis 划分为 Number of Bins 个区间，统计显示批次内落入各区间的样本数。Number of Points 决定流模式中每批观察的样本数量。

Accumulate=No 时更新当前批次分布，Yes 时累加显示计数；Autoscale 控制纵轴范围。该图显示分箱计数，不自动输出均值、方差或经过归一化的概率密度。界面刷新可能跳过数据批次，因此累计显示也不能代替完整数据统计。

## 快速示例

Noise Source 设为 Float、Gaussian、Amplitude=1、Seed=42，经 Float Throttle（32000）接本模块。设置 Type=Float、Number of Points=10000、Number of Bins=100、Min x-axis=-3、Max x-axis=3、Accumulate=No。直方图应呈近似钟形，区间外尾部不计入可见范围。

再把 Noise Type 改为 Uniform、Amplitude 保持 1，把显示范围改为 [-1,1]。直方图应在此范围内近似平坦；不要用只输出整数的 Random Uniform Source 直接连接 Float 输入。

## 性能与部署

分箱数量、观察点数、通道数和更新周期共同影响开销。完整的统计分析应另存原始样本，在相同数据集上计算；图形形状不能替代正式分布检验。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 无法连接 Complex 或整数流 | 输入类型不支持 | 明确转换为要统计的 Float 量 |
| 大部分数据不可见 | 横轴范围不覆盖幅度 | 调整 Min/Max x-axis |
| 柱形起伏很大 | 样本少、分箱过密 | 增大观察点数或减少箱数 |
| 消息模式失败 | 负载不是 f32vector | 检查 uniform vector 或 PDU 的负载类型 |

## 相关 Block

- [Noise Source](Noise_Source.md)：生成已知分布的噪声。
- [Complex to Mag](Complex_to_Mag.md)：生成复数幅度流。
- [File Sink](File_Sink.md)：记录原始样本用于统计。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
