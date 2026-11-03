# Band Reject Filter 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Band Reject Filter

## 概览

Band Reject Filter（带阻滤波器，也称陷波滤波器）衰减特定频率范围内的信号，同时允许该范围之外的信号通过。用于去除特定频段的干扰。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Filters（滤波器） |
| Block ID | `band_reject_filter` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **干扰抑制**  
   去除特定频率的干扰信号

2. **陷波滤波**  
   消除窄带干扰（如工频干扰）

3. **频段隔离**  
   阻止特定频段的信号

4. **信号清理**  
   去除已知的干扰频率

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
| **Low Cutoff Freq** | 浮点数 | 设置下过渡带中点，单位为 Hz |  | ✓ |
| **High Cutoff Freq** | 浮点数 | 设置上过渡带中点，单位为 Hz |  | ✓ |
| **Transition Width** | 浮点数 | 设置过渡带宽度，单位为 Hz | 1 | ✓ |
| **Window** | 枚举 | 选择 FFT 窗函数 | Hamming | ✓ |
| **Beta** | 浮点数 | 设置窗函数形状参数；仅对支持 Beta 的窗函数生效 | 6.76 | ✓ |

## 工作原理

本模块用窗函数法设计带阻 FIR。Cutoff 参数表示过渡带中点，Transition Width 用于确定过渡宽度与抽头数量。通带和阻带都有有限纹波，不能把截止点当作完全通过或完全阻断的边界。

两条过渡带分别以 Low Cutoff Freq、High Cutoff Freq 为中心；稳定阻带约为 Low Cutoff Freq+Transition Width/2 到 High Cutoff Freq−Transition Width/2。阻带两侧为通带。

更窄过渡带通常需要更多抽头。抽取 D 倍时输出速率为输入的 1/D；抗混叠设计应让阻带在输出奈奎斯特频率之前达到所需衰减，不能只检查截止频率。

选择 Interpolating 类型时，输出率为输入的 Interpolation 倍，Sample Rate 填写插值后的设计速率；保持直流幅度时，系数增益通常需包含插值倍数。Decimating 类型则使用抽取前速率。

## 快速示例

**示例 1：去除工频干扰**

```
[Signal] → [Band Reject Filter] → [Processing]
            (49-51Hz, 去除50Hz)
```

**示例 2：去除窄带干扰**

```
[Sensor Input] → [Band Reject Filter] → [Analysis]
              (阻止干扰频段)
```

## 性能与部署

计算量通常随滤波器阶数、FFT 点数、通道数或采样率增加。部署前应在目标采样率下测量持续负载和处理延迟。

## 故障排查

**Q1: 与 Band Pass 有什么区别？**  
A: Band Reject 阻止特定频段，Band Pass 允许特定频段通过。

**Q2: 如何设计陷波滤波器？**  
A: 将 Low 和 High Cutoff 设置得很接近，形成窄带阻。

## 相关 Block

- [Band Pass Filter](Band_Pass_Filter.md)：带通滤波器
- [Low Pass Filter](Low_Pass_Filter.md)：低通滤波器
- [High Pass Filter](High_Pass_Filter.md)：高通滤波器

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
