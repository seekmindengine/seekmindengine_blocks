# Rational Resampler 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Rational Resampler

## 概览

Rational Resampler 模块实现有理数倍率的采样率转换，即输出采样率 = 输入采样率 × (Interpolation / Decimation)。它结合了插值和抽取操作，并使用 FIR 滤波器防止混叠。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Resamplers（重采样器） |
| Block ID | `rational_resampler_xxx` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **采样率转换**  
   在不同采样率的模块之间进行转换

2. **音频重采样**  
   将音频从一个采样率转换到另一个采样率

3. **采集采样率匹配**  
   匹配不同设备的采样率要求

4. **带宽调整**  
   调整信号带宽以适应处理需求

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | 由数据类型参数决定 | 连续样本流端口 |
| 输出 | `默认` | 样本流 | 由数据类型参数决定 | 连续样本流端口 |

> 重采样会改变输出采样率语义和计算负载。确认上下游都使用变换后的采样率，并检查抗混叠条件。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Type** | 枚举 | 选择样本数据类型，必须与相连端口一致 | Float->Float (Real Taps) | ✗ |
| **Interpolation** | 整数 | 设置插值倍数；输出速率为输入速率乘以该值 | 1 | ✗ |
| **Decimation** | 整数 | 设置抽取倍数；输出速率为输入速率除以该值 | 1 | ✗ |
| **Taps** | 类型相关 | 设置滤波器抽头系数 | [] | ✓ |
| **Fractional BW** | 浮点数 | 设置相对采样率归一化的分数带宽 | 0 | ✗ |

## 参数说明

**1. Type**
- 数据类型
  - **Complex->Complex (Complex Taps)**：ccc
  - **Complex->Complex (Real Taps)**：ccf
  - **Float->Complex (Complex Taps)**：fcc
  - **Float->Float (Real Taps)**：fff

**2. Interpolation**
- 内插因子

**3. Decimation**
- 抽取因子

**4. Taps**
- 滤波器抽头系数

**5. Fractional BW**
- 自动设计时的分数通带边缘；有效值在 (0,0.5)，0 表示采用内部默认 0.4。
## 工作原理

**重采样过程：**
```
输入 (fs_in) → 插值 (×Interpolation) → 滤波 → 抽取 (÷Decimation) → 输出 (fs_out)

fs_out = fs_in × (Interpolation / Decimation)
```

**滤波器设计：**
仅当 Taps 为空时自动设计低通。令 f=Fractional BW（0 时用 0.4）、F=min(fs_in,fs_out)，自动设计的通带边缘约为 f×F，过渡带宽为 (0.5−f)×F，设计截止频率位于该过渡带中点。提供自定义 Taps 时，需自行保证增益与抗混叠响应。

## 快速示例

**示例 1：音频重采样（48kHz → 8kHz）**

```
[Audio Source] → [Rational Resampler] → [Audio Processing] → [Audio Sink]
  (48kHz)         (Interp=1, Dec=6)      (8kHz)              (8kHz)
```

配置参数：
- Type: Float->Float (Real Taps)
- Interpolation: 1
- Decimation: 6
- Taps: []
- Fractional BW: 0.4

**示例 2：升采样（200kHz → 2MHz）**

```
[Input Signal] → [Rational Resampler] → [Output Device]
  (200kHz)        (Interp=10, Dec=1)     (2MHz)
```

配置参数：
- Type: Complex->Complex (Real Taps)
- Interpolation: 10
- Decimation: 1
- Fractional BW: 0.4

**示例 3：任意倍率（32kHz → 48kHz）**

```
[File Source] → [Rational Resampler] → [Audio Sink]
  (32kHz)        (Interp=3, Dec=2)      (48kHz)
```

配置参数：
- Interpolation: 3
- Decimation: 2
- 输出采样率 = 32000 × (3/2) = 48000 Hz

**示例 4：自定义滤波器**

## 采样率转换示例

| 输入采样率 | Interpolation | Decimation | 输出采样率 | 应用场景 |
|-----------|--------------|-----------|-----------|---------|
| 48 kHz | 1 | 6 | 8 kHz | 音频降采样 |
| 200 kHz | 1 | 10 | 20 kHz | 音频提取 |
| 32 kHz | 3 | 2 | 48 kHz | 音频升采样 |
| 2 MHz | 1 | 10 | 200 kHz | 目标频带降采样 |
| 250 kHz | 4 | 5 | 200 kHz | 任意转换 |

## 性能与部署

1. **计算复杂度**  
   与滤波器长度和插值因子成正比

2. **滤波器设计**  
   自动设计的滤波器通常足够好，特殊需求可自定义

3. **整数倍率**  
   尽量使用简单的整数比（如 2:1, 3:1）以提高效率

4. **最大公约数**  
   简化 Interpolation 和 Decimation 的比值

## 故障排查

**Q1: 如何计算 Interpolation 和 Decimation？**  
A: 
```
比率 = 输出采样率 / 输入采样率
简化比率为最简分数 = Interpolation / Decimation
例如：48000/32000 = 3/2，所以 Interp=3, Decim=2
```

**Q2: Fractional BW 如何设置？**  
A: 面板默认 0 对应内部默认 0.4。增大有效值会缩窄过渡带、通常增加抽头数量；减小会拓宽过渡带，同时缩小可用通带。

**Q3: 为什么输出有延迟？**  
A: FIR 滤波器引入群延迟，这是正常的。延迟 = (滤波器长度-1) / (2 × 输出采样率)。

**Q4: 可以实现非整数倍率吗？**  
A: 可以，通过有理数近似。例如 1.5 倍 = 3/2。

**Q5: Taps 为空时会怎样？**  
A: 模块会自动设计合适的低通滤波器。

## 相关 Block

- **Fractional Resampler**：任意小数倍率重采样
- [Polyphase Arbitrary Resampler](Polyphase_Arbitrary_Resampler.md)：任意倍率重采样
- [Decimating FIR Filter](Decimating_FIR_Filter.md)：仅降采样
- [Interpolating FIR Filter](Interpolating_FIR_Filter.md)：仅升采样

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
