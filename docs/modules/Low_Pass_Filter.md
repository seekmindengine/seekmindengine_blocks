# Low Pass Filter 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Low Pass Filter

## 概览

Low Pass Filter（低通滤波器）允许低于截止频率的信号通过，同时衰减高于截止频率的信号。这是信号处理中最常用的滤波器之一，采用窗函数法设计 FIR 滤波器。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Filters（滤波器） |
| Block ID | `low_pass_filter` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **抗混叠滤波**  
   在降采样前去除高频分量，防止频谱混叠

2. **目标频带提取**  
   从宽带信号中提取特定频段的信号

3. **噪声抑制**  
   去除高频噪声，提高信噪比

4. **带宽限制**  
   限制信号带宽以满足系统要求

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | 由数据类型参数决定 | 连续样本流端口 |
| 输出 | `默认` | 样本流 | 由数据类型参数决定 | 连续样本流端口 |

> 滤波设计采样率应与系数作用的处理段一致；抽取型按抽取前、插值型按插值后采样率设计，并用已知信号验证频响。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **FIR Type** | 枚举 | 选择滤波器输入输出的数据类型组合 | Float->Float (Decimating) | ✗ |
| **Decimation** | 整数 | 设置抽取倍数；输出速率为输入速率除以该值 | 1 | ✗ |
| **Interpolation** | 整数 | 设置插值倍数；输出速率为输入速率乘以该值 | 1 | ✗ |
| **Gain** | 浮点数 | 设置线性增益系数 | 1 | ✓ |
| **Sample Rate** | 浮点数 | 设置采样率，单位为 Sps | 32000 | ✓ |
| **Cutoff Freq** | 浮点数 | 设置截止频率，单位为 Hz |  | ✓ |
| **Transition Width** | 浮点数 | 设置过渡带宽度，单位为 Hz |  | ✓ |
| **Window** | 枚举 | 选择 FFT 窗函数 | Hamming | ✓ |
| **Beta** | 浮点数 | 设置窗函数形状参数；仅对支持 Beta 的窗函数生效 | 6.76 | ✓ |

## 工作原理

本模块用窗函数法设计低通 FIR。Cutoff 参数表示过渡带中点，Transition Width 用于确定过渡宽度与抽头数量。通带和阻带都有有限纹波，不能把截止点当作完全通过或完全阻断的边界。

用非负频率描述时，通带约到 Cutoff Freq−Transition Width/2，阻带约从 Cutoff Freq+Transition Width/2 开始。实系数滤波器的负频率响应对称。

更窄过渡带通常需要更多抽头。抽取 D 倍时输出速率为输入的 1/D；抗混叠设计应让阻带在输出奈奎斯特频率之前达到所需衰减，不能只检查截止频率。

选择 Interpolating 类型时，输出率为输入的 Interpolation 倍，Sample Rate 填写插值后的设计速率；保持直流幅度时，系数增益通常需包含插值倍数。Decimating 类型则使用抽取前速率。

## 快速示例

**示例 1：基本低通滤波**

```
[Signal Source] → [Add] → [Low Pass Filter] → [QT GUI Frequency Sink]
                    ↑           (1kHz)
              [Noise Source]
```

配置参数：
- FIR Type: Complex->Complex (Decimating)
- Decimation: 1
- Sample Rate: 32000
- Cutoff Freq: 1000
- Transition Width: 200
- Window: Hamming

**示例 2：滤波+降采样**

```
[Acquisition Source] → [Low Pass Filter] → [File Sink]
  (2 MHz)         (100kHz, dec=10)    (200 kHz)
```

配置参数：
- Decimation: 10
- Sample Rate: 2000000
- Cutoff Freq: 100000
- Transition Width: 20000

**示例 3：音频低通滤波**

```
[Audio Source] → [Low Pass Filter] → [Audio Sink]
  (48kHz)          (4kHz cutoff)       (48kHz)
```

配置参数：
- FIR Type: Float->Float (Decimating)
- Decimation: 1
- Sample Rate: 48000
- Cutoff Freq: 4000
- Transition Width: 500
- Window: Blackman

## 性能与部署

1. **计算复杂度**  
   滤波器阶数 = 计算量。窄过渡带需要更多计算

2. **延迟**  
   FIR 滤波器延迟 = (N-1) / (2 × Sample_Rate)，N 为阶数

3. **内存使用**  
   需要存储 N 个滤波器系数和延迟线

## 故障排查

**Q1: 如何选择截止频率？**  
A: 根据信号带宽和应用需求。通常设为信号带宽的 1.1-1.5 倍。

**Q2: Transition Width 如何设置？**  
A: 越小滤波器越陡峭但计算量越大。通常设为截止频率的 10-20%。

**Q3: 为什么滤波后信号延迟了？**  
A: FIR 滤波器有固有的群延迟。可以通过后续处理补偿。

**Q4: Decimation 和单独的 Decimate 模块有什么区别？**  
A: 集成的抽取更高效，先滤波再降采样，避免混叠。

## 相关 Block

- [High Pass Filter](High_Pass_Filter.md)：高通滤波器
- [Band Pass Filter](Band_Pass_Filter.md)：带通滤波器
- [Band Reject Filter](Band_Reject_Filter.md)：带阻滤波器
- [Rational Resampler](Rational_Resampler.md)：有理数重采样

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
