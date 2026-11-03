# Band Pass Filter 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Band Pass Filter

## 概览

Band Pass Filter（带通滤波器）允许特定频率范围内的信号通过，同时衰减该范围之外的信号。它结合了高通和低通滤波的特性，用于提取特定频段的信号。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Filters（滤波器） |
| Block ID | `band_pass_filter` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **目标频带提取**  
   从宽带信号中提取特定频段

2. **干扰抑制**  
   去除带外干扰和噪声

3. **频段隔离**  
   分离不同频段的信号

4. **采集链路前端**  
   选择感兴趣的频率范围

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | 由数据类型参数决定 | 连续样本流端口 |
| 输出 | `默认` | 样本流 | 由数据类型参数决定 | 连续样本流端口 |

> 滤波设计采样率应与系数作用的处理段一致；抽取型按抽取前、插值型按插值后采样率设计，并用已知信号验证频响。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **FIR Type** | 枚举 | 选择滤波器输入输出的数据类型组合 | Float->Float (Real Taps) (Decim) | ✗ |
| **Decimation** | 整数 | 设置抽取倍数；输出速率为输入速率除以该值 | 1 | ✗ |
| **Interpolation** | 整数 | 设置插值倍数；输出速率为输入速率乘以该值 | 1 | ✗ |
| **Gain** | 浮点数 | 设置线性增益系数 | 1 | ✓ |
| **Sample Rate** | 浮点数 | 设置采样率，单位为 Sps | 32000 | ✓ |
| **Low Cutoff Freq** | 浮点数 | 设置下过渡带中点，单位为 Hz | 0 | ✓ |
| **High Cutoff Freq** | 浮点数 | 设置上过渡带中点，单位为 Hz | 1 | ✓ |
| **Transition Width** | 浮点数 | 设置过渡带宽度，单位为 Hz | 1 | ✓ |
| **Window** | 枚举 | 选择 FFT 窗函数 | Hamming | ✓ |
| **Beta** | 浮点数 | 设置窗函数形状参数；仅对支持 Beta 的窗函数生效 | 6.76 | ✓ |

## 工作原理

本模块用窗函数法设计带通 FIR。Cutoff 参数表示过渡带中点，Transition Width 用于确定过渡宽度与抽头数量。通带和阻带都有有限纹波，不能把截止点当作完全通过或完全阻断的边界。

两条过渡带分别以 Low Cutoff Freq、High Cutoff Freq 为中心；稳定通带约为 Low Cutoff Freq+Transition Width/2 到 High Cutoff Freq−Transition Width/2。应给两条过渡带留出足够空间。

更窄过渡带通常需要更多抽头。抽取 D 倍时输出速率为输入的 1/D；抗混叠设计应让阻带在输出奈奎斯特频率之前达到所需衰减，不能只检查截止频率。

选择 Interpolating 类型时，输出率为输入的 Interpolation 倍，Sample Rate 填写插值后的设计速率；保持直流幅度时，系数增益通常需包含插值倍数。Decimating 类型则使用抽取前速率。

## 快速示例

**示例 1：提取音频频段**

```
[Acoustic Source] → [Band Pass Filter] → [Envelope] → [Audio Sink]
  (2MHz)         (10k-15kHz)
```

配置参数：
- Sample Rate: 2000000
- Low Cutoff Freq: 10000
- High Cutoff Freq: 15000
- Transition Width: 1000

**示例 2：目标频带提取**

```
[Wideband Signal] → [Band Pass Filter] → [Detector]
                     (center±BW/2)
```

**示例 3：干扰抑制**

```
[Sensor Input] → [Band Pass Filter] → [Processing]
              (保留信号频段)
```

## 性能与部署

计算量通常随滤波器阶数、FFT 点数、通道数或采样率增加。部署前应在目标采样率下测量持续负载和处理延迟。

## 故障排查

**Q1: 如何设计带通滤波器？**  
A: 确定中心频率和带宽，然后设置 Low/High Cutoff。

**Q2: 与两个滤波器级联有什么区别？**  
A: Band Pass Filter 是单个优化的滤波器，效率更高。

**Q3: 可以用于复数信号吗？**  
A: 可以，选择 Complex 类型。

## 相关 Block

- [Low Pass Filter](Low_Pass_Filter.md)：低通滤波器
- [High Pass Filter](High_Pass_Filter.md)：高通滤波器
- [Band Reject Filter](Band_Reject_Filter.md)：带阻滤波器

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
