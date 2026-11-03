# Quadrature Demod 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Quadrature Demod

## 概览

Quadrature Demod 模块对复数基带信号进行相位差分，输出瞬时频率变化对应的浮点信号。它常用于 FM 解调、FSK/GMSK 前级鉴频和相位变化检测。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Demodulators（解调器） |
| Block ID | `analog_quadrature_demod_cf` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **FM 解调**  
   将复数调频信号转换为音频或基带变化量

2. **FSK/GMSK 鉴频**  
   为后续判决或时钟恢复提供实数输出

3. **相位变化分析**  
   观察连续样本间的相位旋转速度

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | `complex` | 连续样本流端口 |
| 输出 | `默认` | 样本流 | `float` | 连续样本流端口 |

> 收发两端应约定调制和编码方式；每符号采样数按当前处理段的采样率计算，接收环路参数则按输入信号与同步需求设置。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---------|------|------|--------|
| **Gain** | 浮点数 | 输出缩放系数 | 1 |

## 工作原理

模块计算相邻复数样本之间的相位差，并乘以 Gain：

```
out[n] = Gain × arg(in[n] × conj(in[n-1]))
```

## 参数说明

**1. Gain（增益）**
- 对相位差输出进行线性缩放
- 不改变鉴频原理，只改变输出幅度
- FM 解调中常按采样率和最大频偏进行归一化

## 输出含义

Quadrature Demod 输出的是相邻样本的相位变化量，可理解为瞬时频率偏移的离散估计。输入必须是 complex，因为实数流没有完整 IQ 相位信息。

典型关系：

```
相位旋转越快 → 输出幅度越大
旋转方向相反 → 输出符号相反
```

## 配置注意

1. **先做信道滤波**  
   宽带噪声会直接影响相位差估计，通常先 Low Pass/Band Pass。

2. **输入幅度过低会恶化输出**  
   当 IQ 幅度接近 0 时，相位不稳定，鉴频输出会抖动。

3. **Gain 只做缩放**  
   Gain 不会修复频偏、噪声或过采样设置错误。

## 快速示例

```
[USRP Source] → [Low Pass Filter] → [Quadrature Demod] → [Audio Sink]
```

**示例 2：FSK/GMSK 前级判决**

```
[Complex FSK] → [Quadrature Demod] → [Binary Slicer] → [Pack K Bits]
```

**示例 3：观察瞬时频率**

```
[Signal Source] → [Quadrature Demod] → [QT GUI Time Sink]
```

## 典型应用场景

- 窄带 FM 解调
- FSK/GMSK 鉴频
- 相位连续调制分析
- 频率偏移趋势观察

## 性能与部署

在目标采样率和数据规模下验证 CPU、内存与端到端延迟。动态参数、向量长度和并行通道增加时应重新测量。

## 故障排查

**Q1: 输入为什么必须是 complex？**  
A: 正交解调需要复数样本的相位信息，实数信号无法直接提供完整相位旋转。

**Q2: Gain 如何设置？**  
A: 常根据采样率和最大频偏设置，用于把相位差缩放到合适幅度。

## 相关 Block

- [Low Pass Filter](Low_Pass_Filter.md)：信道滤波
- [Binary Slicer](Binary_Slicer.md)：硬判决
- [GMSK Demod](GMSK_Demod.md)：GMSK 解调

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
