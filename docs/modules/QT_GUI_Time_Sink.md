# QT GUI Time Sink 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / QT GUI Time Sink

## 概览

QT GUI Time Sink 显示 Float 或 Complex 样本随时间的变化，支持多输入、触发和样本消息显示。Complex 输入的实部、虚部分别显示为两条曲线。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Instrumentation（仪器测量） |
| Block ID | `qtgui_time_sink_x` |
| 处理模型 | 连续样本流 |
| 典型位置 | Sink（数据终点） |
| 执行支持 | Python / C++ |

## 何时使用

- 观察波形、幅度、周期和瞬态。
- 比较多路信号的时间关系。
- 使用电平或标签触发显示选定片段。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `0 .. Number of Inputs-1` | 样本流 | float 或 complex | Type 为 Float/Complex 时使用 |
| 输入 | `in` | 消息 | f32vector/c32vector 或含相应向量的 PDU | Type 为相应 Message 模式时使用 |

显示器没有样本输出。Complex 模式显示 I/Q，不自动换成幅度与相位；需要幅度时先计算相应实数流。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Type** | 枚举 | 选择样本数据类型，必须与相连端口一致 | Float | ✗ |
| **Name** | 字符串 | 设置界面标题或实例名称 |  | ✗ |
| **Y Axis Label** | 字符串 | 设置 Y 轴标题 | Amplitude | ✗ |
| **Y Axis Unit** | 字符串 | 设置 Y 轴显示单位 |  | ✗ |
| **Number of Points** | 整数 | 设置每次显示或计算的点数 | 1024 | ✗ |
| **Sample Rate** | float | 设置采样率，单位为 Sps | 32000 | ✓ |
| **Grid** | 枚举 | 控制绘图区网格是否显示 | No | ✗ |
| **Autoscale** | 枚举 | 控制坐标范围是否根据输入数据自动调整 | No | ✗ |
| **Y min** | float | 设置 Y 轴显示下限 | -1 | ✓ |
| **Y max** | float | 设置 Y 轴显示上限 | 1 | ✓ |
| **Number of Inputs** | 整数 | 设置输入端口数量 | 1 | ✗ |
| **Update Period** | float | 设置界面刷新周期，单位为秒 | 0.10 | ✓ |
| **Disp. Tags** | 枚举 | 控制标签信息是否叠加到图形中 | Yes | ✗ |
| **GUI Hint** | gui_hint | 设置组件在界面布局中的位置与跨度 |  | ✗ |
| **Trigger Mode** | 枚举 | 选择自由运行、自动或指定条件触发 | Free | ✓ |
| **Trigger Slope** | 枚举 | 选择上升沿或下降沿触发 | qtgui.TRIG_MODE_POS | ✓ |
| **Trigger Level** | float | 设置触发阈值 | 0.0 | ✓ |
| **Trigger Delay** | float | 设置触发点相对显示窗口的延迟 | 0 | ✓ |
| **Trigger Channel** | 整数 | 选择用于触发判定的输入通道 | 0 | ✓ |
| **Trigger Tag Key** | 字符串 | 设置用于标签触发的键名 |  | ✓ |
| **Control Panel** | 枚举 | 控制交互式控制面板是否显示 | No | ✗ |
| **Legend** | 枚举 | 控制图例是否显示 | Yes | ✗ |
| **Axis Labels** | 枚举 | 控制坐标轴标签是否显示 | Yes | ✗ |
| **Stem Plot** | 枚举 | 控制是否使用离散茎叶图方式显示 | No | ✗ |
| **Line 1..10 Label** | 字符串 | 设置各路曲线的图例名称 | 各通道预设值 | ✗ |
| **Line 1..10 Width** | 整数 | 设置各路曲线的线宽 | 1 | ✗ |
| **Line 1..10 Color** | 枚举 | 设置各路曲线的显示颜色 | 各通道预设值 | ✗ |
| **Line 1..10 Style** | 枚举 | 设置各路曲线的线型 | Solid | ✗ |
| **Line 1..10 Marker** | 枚举 | 设置各路曲线的数据点标记 | None | ✗ |
| **Line 1..10 Alpha** | 浮点数 | 设置各路曲线的透明度 | 各通道预设值 | ✗ |

Line 1..10 为重复的通道样式参数，按当前输入数量使用；各通道初值以面板为准。

## 工作原理

按 Number of Points 收集波形，以 `t=n/Sample Rate` 标定横轴。Sample Rate 改变时间轴解释，不重采样输入，也不控制实际供数速度。

Free 模式周期显示；Normal 模式等待触发条件；Auto 在未持续满足触发时仍可更新；Tag 按指定标签触发。Trigger Channel 指显示曲线索引，复数输入需要区分 I/Q。

当前 Trigger Slope 初始字段与可选项存在不一致，首次配置时显式选择 Positive 或 Negative。

## 快速示例

Float Signal Source 设置 Sample Rate=32000、Frequency=1000、Amplitude=0.8，经过 Float Throttle（32000）接本模块。Type=Float、Number of Points=1024、Sample Rate=32000、Trigger Mode=Free、Trigger Slope=Positive、Y min=-1、Y max=1。

应显示约 ±0.8 的波形，周期约 1 ms；1024 点覆盖约 32 ms。切换到 Normal、Trigger Level=0、Trigger Slope=Positive 后，可观察上升过零触发。

## 性能与部署

点数、曲线数量和 Update Period 影响界面负载。显示可能跳过批次，不保证捕获每个短瞬态；需要完整记录时另接文件 Sink。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 时间轴不对 | Sample Rate 与当前流采样率不符 | 按重采样后的速率设置 |
| Normal/Tag 模式不刷新 | 未满足触发条件 | 先切 Free 验证，再检查触发配置 |
| 触发斜率初始化失败 | 初始枚举字段不一致 | 显式重新选择 Positive 或 Negative |
| Complex 显示两条线 | 分别显示实部、虚部 | 按 I/Q 解读或先计算幅度 |
| 消息模式报类型错误 | PDU 向量类型与 Type 不匹配 | 使用 f32vector 或 c32vector |

## 相关 Block

- [QT GUI Frequency Sink](QT_GUI_Frequency_Sink.md)：观察频谱。
- [Complex to Mag](Complex_to_Mag.md)：计算复数幅度。
- [File Sink](File_Sink.md)：记录完整样本。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
