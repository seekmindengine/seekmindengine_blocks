# FFT Low Pass Filter 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / FFT Low Pass Filter

## 概览

FFT Low Pass Filter 模块是专门优化的 FFT 域低通滤波器。它结合了 FFT 滤波的高效性和低通滤波器的常用性，提供了简化的接口来实现高性能的低通滤波。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Filters（滤波器） |
| Block ID | `filter_fft_low_pass_filter` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | 平台内置 |

## 何时使用

1. **高效低通滤波**  
   使用 FFT 方法实现长低通滤波器

2. **带宽限制**  
   限制信号带宽防止混叠

3. **抗混叠滤波**  
   抽取前的抗混叠处理

4. **信号平滑**  
   去除高频噪声

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | 由数据类型参数决定 | 连续样本流端口 |
| 输出 | `默认` | 样本流 | 由数据类型参数决定 | 连续样本流端口 |

> 滤波设计采样率应与系数作用的处理段一致；抽取型按抽取前、插值型按插值后采样率设计，并用已知信号验证频响。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Type** | 枚举 | 选择样本数据类型，必须与相连端口一致 | Float->Float (Real Taps) | ✗ |
| **Decimation** | 整数 | 设置抽取倍数；输出速率为输入速率除以该值 | 1 | ✗ |
| **Gain** | 浮点数 | 设置线性增益系数 | 1 | ✓ |
| **Sample Rate** | 浮点数 | 设置采样率，单位为 Sps | 32000 | ✓ |
| **Cutoff Freq** | 浮点数 | 设置截止频率，单位为 Hz |  | ✓ |
| **Transition Width** | 浮点数 | 设置过渡带宽度，单位为 Hz |  | ✓ |
| **Window** | 原始 | 选择 FFT 窗函数 | Hamming | ✓ |
| **Beta** | 浮点数 | 设置窗函数形状参数；仅对支持 Beta 的窗函数生效 | 6.76 | ✓ |
| **Num. Threads** | 整数 | 设置处理线程数量；增加前应测量吞吐与调度开销 | 1 | ✓ |

## 工作原理

本模块用窗函数法设计低通 FIR。Cutoff 参数表示过渡带中点，Transition Width 用于确定过渡宽度与抽头数量。通带和阻带都有有限纹波，不能把截止点当作完全通过或完全阻断的边界。

用非负频率描述时，通带约到 Cutoff Freq−Transition Width/2，阻带约从 Cutoff Freq+Transition Width/2 开始。实系数滤波器的负频率响应对称。

更窄过渡带通常需要更多抽头。抽取 D 倍时输出速率为输入的 1/D；抗混叠设计应让阻带在输出奈奎斯特频率之前达到所需衰减，不能只检查截止频率。 FFT 实现按块执行重叠相加卷积，内部 FFT 大小由抽头数量确定。

## 快速示例

**示例 1：基本低通滤波**

```
[Signal] → [FFT Low Pass Filter] → [Output]
  (32 kHz)  (fc=4 kHz)               (带限)
```

配置参数：
- Sample Rate: 32000
- Cutoff Freq: 4000
- Transition Width: 500

**示例 2：抗混叠滤波**

```
[Signal] → [FFT Low Pass Filter] → [Output]
  (2 MHz)   (Dec=4, fc=250 kHz)      (500 kHz)
```

配置参数：
- Decimation: 4
- Cutoff Freq: 250000  (< 500k/2)
- 防止混叠

**示例 3：音频滤波**

```
[Audio] → [FFT Low Pass Filter] → [Speaker]
           (fc=15 kHz)
```

配置参数：
- Sample Rate: 48000
- Cutoff Freq: 15000
- 去除超声波

**示例 4：目标频带提取**

```
[Wideband] → [FFT Low Pass Filter] → [Analysis]
              (提取频带)
```

配置参数：
- Cutoff Freq: 目标频带带宽/2
- Transition Width: 窄过渡带

**示例 5：噪声抑制**

```
[Noisy Signal] → [FFT Low Pass Filter] → [Clean Signal]
                  (去除高频噪声)
```

## 性能与部署

1. **滤波器长度**  
   - 自动根据参数计算
   - 窄过渡带 → 长滤波器
   - FFT 方法对长滤波器高效

2. **计算复杂度**  
   - O(N log N) per block
   - 比时域 FIR 更高效（长滤波器）

3. **延迟**  
   - 群延迟 ≈ N/2 样本
   - N = 滤波器长度

4. **内存使用**  
   - 需要 FFT 缓冲区
   - 与 FFT 大小成正比

## 故障排查

**Q1: 与普通 Low Pass Filter 有什么区别？**  
A: 
- FFT Low Pass：频域实现，适合长滤波器
- Low Pass Filter：时域实现，适合短滤波器

**Q2: 如何选择截止频率？**  
A: 根据需要保留的信号带宽，通常设为信号带宽的 1.1-1.2 倍。

**Q3: 过渡带宽如何影响性能？**  
A: 
- 窄过渡带：更陡峭，但需要更多抽头
- 宽过渡带：更少抽头，但不够陡峭

**Q4: 可以用于实时应用吗？**  
A: 可以，但要注意延迟。

**Q5: 如何减少延迟？**  
A: 
- 增加过渡带宽（减少抽头数）
- 使用较小的 FFT 块

**Q6: 支持动态改变参数吗？**  
A: 可以重新设计滤波器并更新抽头。

**Q7: 与 Decimating FIR Filter 相比？**  
A: FFT 方法对长滤波器更高效，但有更大延迟。

## 相关 Block

- [Low Pass Filter](Low_Pass_Filter.md)：时域低通滤波器
- [FFT Filter](FFT_Filter.md)：通用 FFT 滤波器
- [Decimating FIR Filter](Decimating_FIR_Filter.md)：带抽取的 FIR
- [Rational Resampler](Rational_Resampler.md)：重采样器

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
