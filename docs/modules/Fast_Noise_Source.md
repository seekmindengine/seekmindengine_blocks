# Fast Noise Source 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Fast Noise Source

## 概览

Fast Noise Source 预先生成有限的噪声样本池，运行时随机选取池中的样本输出。它将逐样本分布生成替换为随机查表，可用于评估噪声生成开销与样本池统计误差之间的取舍。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Waveform Generators（波形发生器） |
| Block ID | `analog_fastnoise_source_x` |
| 处理模型 | 连续样本流 |
| 典型位置 | Source（数据源） |
| 执行支持 | Python / C++ |

## 何时使用

- 在较高样本率下评估噪声生成性能。
- 使用固定种子和池大小构建可重复的测试。
- 比较不同池大小对功率、直方图和检测统计量的影响。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输出 | `默认` | 样本流 | complex、float、int 或 short | 从预生成池随机选择的噪声样本 |

模块没有输入端口。与信号合成时，必须通过 Add 的另一输入叠加。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Output Type** | 枚举 | 选择输出端样本类型 | float | ✗ |
| **Noise Type** | 原始 | 选择噪声概率分布类型 | Gaussian | ✓ |
| **Amplitude** | 浮点数 | 设置输出幅度 | 1 | ✓ |
| **Seed** | 整数 | 设置随机数种子；固定值可复现实验结果 | 0 | ✗ |
| **Variate Pool Size** | 整数 | 设置预生成随机变量池的容量 | 8192 | ✗ |

## 工作原理

初始化时按 Noise Type、Amplitude 和 Seed 生成 Variate Pool Size 个值，运行时通过伪随机索引选择输出。更新 Noise Type 或 Amplitude 会重新生成样本池。

设 Amplitude=A。Float Gaussian 的方差和平均功率为 A²；Complex Gaussian 的 I、Q 各按 A/√2 缩放，因此总平均功率同样为 A²。

Float Uniform 分布范围为 `[-A,A)`，平均功率为 A²/3；Complex Uniform 的每个分量范围为 `[-A/√2,A/√2)`，总平均功率为 A²/3。整数输出还会发生量化，不能直接套用浮点公式。

Complex 输出仅支持 Gaussian 和 Uniform；Laplacian 与 Impulse 用于实数类型。

池的有限样本分布决定长期输出统计特性，尾部事件可能在池中缺失。相同版本、种子、参数及更新操作序列可以产生相同结果；各实例并不自动取得不同种子。

## 快速示例

Signal Source 设为 Complex、Cosine、Sample Rate=32000、Frequency=1000、Amplitude=1。噪声源设为 Complex、Gaussian、Amplitude=0.1、Seed=42。两路接 Add（Complex、两输入），再接 Throttle（Complex、32000）和 QT GUI Frequency Sink（Complex、Bandwidth=32000）。

单位幅度复数单音功率为 1，噪声期望功率为 0.01，故输入 SNR 约为 20 dB。若改为峰值幅度 1 的实数正弦，其功率为 0.5，同样噪声幅度下 SNR 约为 17 dB。有限样本测量会有统计波动。

Variate Pool Size 先设为 8192，再改为 32768，分别记录足够长的输出，比较均值、功率与直方图。观察到的差异应结合池大小和种子判断。

## 性能与部署

- 池大小必须为正整数；2 的幂可使用位掩码选择索引。
- 池内存约为“池大小 × 元素字节数”；8192 个 Complex 样本约占 64 KiB，另有对象开销。
- 较大的池增加初始化时间和内存占用；性能改善幅度需在目标机器上测量。
- 低概率事件或精确误码率实验应检验池分布，不把长时间重复抽样当成无限的新噪声样本。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 不同噪声源输出相同 | 种子和池参数相同 | 为不同测试通道显式设置种子 |
| 均值/功率偏离理论值 | 有限池的统计波动 | 换种子、增大池，并测量实际统计量 |
| 调参时短暂停顿 | 重新生成样本池 | 评估池大小和调参频率 |
| Complex 模式失败 | 选择了不支持的分布 | 使用 Gaussian 或 Uniform |

## 相关 Block

- [Noise Source](Noise_Source.md)：运行时逐样本生成噪声。
- [Random Source](Random_Source.md)：有限整数序列源。
- [Add](Add.md)：叠加信号与噪声。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
