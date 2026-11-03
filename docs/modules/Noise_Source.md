# Noise Source 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Noise Source

## 概览

Noise Source 按所选分布持续生成伪随机噪声。实数类型支持 Uniform、Gaussian、Laplacian 和 Impulse；复数类型支持 Uniform 和 Gaussian。它通常作为独立输入，与待测信号通过 Add 叠加。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Waveform Generators（波形发生器） |
| Block ID | `analog_noise_source_x` |
| 处理模型 | 连续样本流 |
| 典型位置 | Source（数据源） |
| 执行支持 | Python / C++ |

## 何时使用

- 构造可重复的噪声环境，检查滤波、检测或解调结果。
- 按信号功率设置噪声幅度，开展 SNR 扫描。
- 生成噪声记录并检验分布与频谱。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输出 | `默认` | 样本流 | complex、float、int 或 short | 连续噪声样本 |

没有输入端口或采样率参数。要向信号添加噪声，应将二者接入 Add 的不同输入；需要近似实时观察时，可在合并后的路径上限速。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Output Type** | 枚举 | 选择输出端样本类型 | float | ✗ |
| **Noise Type** | 原始 | 选择噪声概率分布类型 | Gaussian | ✓ |
| **Amplitude** | 浮点数 | 设置输出幅度 | 1 | ✓ |
| **Seed** | 整数 | 设置随机数种子；固定值可复现实验结果 | 0 | ✗ |

## 工作原理

设 Amplitude=A。Float Gaussian 的方差和平均功率为 A²；Complex Gaussian 的 I、Q 各按 A/√2 缩放，因此总平均功率同样为 A²。

Float Uniform 分布范围为 `[-A,A)`，平均功率为 A²/3；Complex Uniform 的每个分量范围为 `[-A/√2,A/√2)`，总平均功率为 A²/3。整数输出还会发生量化，不能直接套用浮点公式。

Complex 输出仅支持 Gaussian 和 Uniform；Laplacian 与 Impulse 用于实数类型。

当前实现构造时直接使用 Seed，包括 0。相同版本、种子和参数用于复现初始序列；需要不同序列时显式改变种子。不要把 Seed=0 理解为自动使用系统时间。

## 快速示例

Signal Source 设为 Complex、Cosine、Sample Rate=32000、Frequency=1000、Amplitude=1。噪声源设为 Complex、Gaussian、Amplitude=0.1、Seed=42。两路接 Add（Complex、两输入），再接 Throttle（Complex、32000）和 QT GUI Frequency Sink（Complex、Bandwidth=32000）。

单位幅度复数单音功率为 1，噪声期望功率为 0.01，故输入 SNR 约为 20 dB。若改为峰值幅度 1 的实数正弦，其功率为 0.5，同样噪声幅度下 SNR 约为 17 dB。有限样本测量会有统计波动。

## 性能与部署

运行时逐样本生成噪声，CPU 开销与分布、类型和样本率有关。不同实例如果使用相同种子与参数，可能产生相同序列；多通道仿真需明确各路种子。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| Complex 模式报 invalid type | 选择了 Laplacian 或 Impulse | 改用受支持的分布或实数类型 |
| SNR 差约 3 dB | 混用了实正弦和复数单音的功率公式 | 先测信号平均功率，再计算 A=√噪声功率 |
| 每次启动噪声相同 | 种子与参数未变化 | 这是可重复行为；需要不同序列时更换种子 |
| 整数噪声幅度很小或大量为零 | 幅度不足以跨越整数刻度 | 使用 Float，或按整数范围设置幅度 |

## 相关 Block

- [Fast Noise Source](Fast_Noise_Source.md)：更快的噪声生成器
- [Random Source](Random_Source.md)：生成随机整数序列
- [Signal Source](Signal_Source.md)：生成确定性信号
- [Add](Add.md)：将噪声添加到信号

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
