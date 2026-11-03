# QT GUI Frequency Sink 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / QT GUI Frequency Sink

## 概览

QT GUI Frequency Sink 对 float 或 complex 输入执行加窗 FFT 并显示频谱。Type 可选择样本流模式或消息模式；可选消息端口用于更新中心频率和带宽，并可输出频率交互消息。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Instrumentation（仪器测量） |
| Block ID | `qtgui_freq_sink_x` |
| 处理模型 | 连续样本流与可选消息，或消息输入模式 |
| 典型位置 | Sink / GUI |
| 执行支持 | Python / C++ |

## 何时使用

用于观察实时频谱、中心频率和带宽范围。若需要把计算结果作为流继续处理，应使用 FFT 或 Log Power FFT，而不是依赖 GUI Sink。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | 默认 | 样本流 | `complex` 或 `float` | 当前编辑器定义只暴露一路流输入，Number of Inputs 保持 1 |
| 输入 | `freq` | 消息 | 由组件 API 定义 | Show Msg Ports=Yes 时可选 |
| 输入 | `bw` | 消息 | 由组件 API 定义 | Show Msg Ports=Yes 时可选 |
| 输出 | `freq` | 消息 | 由组件 API 定义 | Show Msg Ports=Yes 时可选 |

运行接口支持 `in` 样本消息（f32vector/c32vector 或相应 PDU），但当前编辑器定义未暴露该端口；本页示例使用流模式。

## 参数

| 参数名称 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| **Type** | enum | `Float` | Complex、Float 或相应 Message 模式 |
| **Name** | string | 空 | 图标题 |
| **FFT Size** | int enum | `1024` | 32 到 32768，且必须为 2 的幂 |
| **Spectrum Width** | enum | `Full` | float 模式显示 Full 或 Half |
| **Window Type** | enum | `Blackman-harris` | FFT 窗函数 |
| **Normalize Window Power** | enum | `False` | 是否归一化窗功率 |
| **Center Frequency (Hz)** | real | `0` | 频率轴中心 |
| **Bandwidth (Hz)** | real | `32000` | 频率轴跨度，通常设为该段采样率 |
| **Number of Inputs** | int | `1` | 流模式输入数量 |
| **Grid** | enum | `No` | 显示网格 |
| **Autoscale** | enum | `No` | 自动缩放 Y 轴 |
| **Average** | enum | `False` | FFT 时间平均系数预设 |
| **Y min** | real | `-140` | Y 轴下限 |
| **Y max** | real | `10` | Y 轴上限 |
| **Y label** | string | `Relative Gain` | Y 轴标签 |
| **Y units** | string | `dB` | Y 轴单位文字 |
| **Update Period** | real | `0.10` s | GUI 更新周期 |
| **Show Msg Ports** | bool | `No` | 显示 `freq`/`bw` 消息端口 |
| **GUI Hint** | gui_hint | 空 | Qt GUI 布局位置 |
| **Trigger Mode** | enum | `Free` | Free、Auto、Normal 或 Tag |
| **Trigger Level** | float | `0.0` | 触发电平 |
| **Trigger Channel** | int | `0` | 触发输入索引 |
| **Trigger Tag Key** | string | 空 | Tag 模式使用的 key |
| **Control Panel** | enum | `No` | 显示交互控制面板 |
| **Legend** | enum | `Yes` | 显示图例 |
| **Axis Labels** | enum | `Yes` | 显示坐标轴标签 |
| **Line 1 Label** | string | 空 | 每个输入的图例名称 |
| **Line 1 Width** | int | `1` | 每个输入的线宽 |
| **Line 1 Color** | enum | 各通道预设色 | 每个输入的颜色 |
| **Line 1 Alpha** | float | `1.0` | 每个输入的不透明度 |

当前面板定义仅保留 Line 1 的样式参数，且默认隐藏；不要据此假定可配置 10 路独立曲线。Frequency Sink 没有 Line Style 或 Marker 参数。

## 工作原理

Block 对输入窗口加窗、执行 FFT、计算显示量并按 Average 配置平滑，然后以 Center Frequency 和 Bandwidth 标定横轴。FFT bin 间隔约为：

```text
bin_width = Bandwidth / FFT_Size
```

显示的绝对幅值取决于窗函数、归一化、输入标定和 Y 轴单位，不应从默认图形推断经过校准的 dBFS、dBm 或 PSD。

## 快速示例

```text
[Signal Source (float, 32 kSps)] -> [Throttle] -> [QT GUI Frequency Sink]
```

设置 Type=`Float`、FFT Size=`1024`、Center Frequency=`0`、Bandwidth=`32000`。1 kHz 输入应在 1 kHz 附近形成谱峰。

## 性能与部署

FFT Size、输入数量和 Update Period 共同影响 GUI 负载。需要处理结果供下游使用时改用非 GUI FFT Block。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 频率轴错误 | Bandwidth 不等于当前处理段采样率 | 按 rate change 后的实际速率设置 |
| FFT Size 校验失败 | 超出范围或不是 2 的幂 | 使用 32 到 32768 的 2 次幂 |
| 消息端口不可见 | Show Msg Ports=No | 启用后再连接 `freq`/`bw` |
| 幅值与预期不符 | 窗、归一化或单位假设不同 | 固定配置并用已知输入标定 |

## 相关 Block

- [FFT](FFT.md)：输出频域向量供后续处理
- [Log Power FFT](Log_Power_FFT.md)：输出对数功率谱流
- [QT GUI Waterfall Sink](QT_GUI_Waterfall_Sink.md)：显示频谱随时间变化

---

[返回 Block 目录](../../README.md#block-目录)
