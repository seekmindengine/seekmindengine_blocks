# High Pass Filter 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / High Pass Filter

## 概览

High Pass Filter（高通滤波器）允许高于截止频率的信号通过，同时衰减低于截止频率的信号。常用于去除低频干扰和直流分量。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Filters（滤波器） |
| Block ID | `high_pass_filter` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **去除低频干扰**  
   消除低频噪声和干扰

2. **直流去除**  
   去除信号中的直流分量

3. **高频信号提取**  
   提取高频成分

4. **信号预处理**  
   为后续处理准备信号

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

本模块用窗函数法设计高通 FIR。Cutoff 参数表示过渡带中点，Transition Width 用于确定过渡宽度与抽头数量。通带和阻带都有有限纹波，不能把截止点当作完全通过或完全阻断的边界。

用非负频率描述时，阻带约到 Cutoff Freq−Transition Width/2，通带约从 Cutoff Freq+Transition Width/2 开始。实系数滤波器的负频率响应对称。

更窄过渡带通常需要更多抽头。抽取 D 倍时输出速率为输入的 1/D；抗混叠设计应让阻带在输出奈奎斯特频率之前达到所需衰减，不能只检查截止频率。

选择 Interpolating 类型时，输出率为输入的 Interpolation 倍，Sample Rate 填写插值后的设计速率；保持直流幅度时，系数增益通常需包含插值倍数。Decimating 类型则使用抽取前速率。

## 快速示例

**示例 1：去除低频噪声**

```
[Signal] → [High Pass Filter] → [Processing]
            (cutoff=100Hz)
```

**示例 2：提取高频成分**

```
[Audio] → [High Pass Filter] → [Analysis]
           (cutoff=5kHz)
```

## 性能与部署

计算量通常随滤波器阶数、FFT 点数、通道数或采样率增加。部署前应在目标采样率下测量持续负载和处理延迟。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 流程无法连接 | 数据类型、向量长度或端口数量不匹配 | 对照“输入与输出”统一连接契约 |
| 运行结果异常 | 采样率语义或关键参数不一致 | 使用确定性输入，从默认参数逐项验证 |

更多通用排查方法见[故障排查指南](../TROUBLESHOOTING.md)。

## 相关 Block

- [Low Pass Filter](Low_Pass_Filter.md)：低通滤波器
- [Band Pass Filter](Band_Pass_Filter.md)：带通滤波器
- [DC Blocker](DC_Blocker.md)：专门去除 DC

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
