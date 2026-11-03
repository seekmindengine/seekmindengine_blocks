# Decimating FIR Filter 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Decimating FIR Filter

## 概览

Decimating FIR Filter 结合了 FIR 滤波和降采样（抽取）操作。它先对信号进行滤波以防止混叠，然后降低采样率。这种集成实现比分别使用滤波器和抽取器更高效。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Filters（滤波器） |
| Block ID | `fir_filter_xxx` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **降采样**  
   降低信号的采样率同时防止混叠

2. **目标频带提取**  
   提取宽带信号中的窄带目标分量

3. **计算负载降低**  
   减少后续处理的数据率

4. **多速率信号处理**  
   实现多速率滤波器组

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | 由数据类型参数决定 | 连续样本流端口 |
| 输出 | `默认` | 样本流 | 由数据类型参数决定 | 连续样本流端口 |

> 滤波设计采样率应与系数作用的处理段一致；抽取型按抽取前、插值型按插值后采样率设计，并用已知信号验证频响。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---------|------|------|--------|
| **Type** | 枚举 | 数据类型 | Float->Float (Real Taps) |
| **Decimation** | 整数 | 抽取因子 | 1 |
| **Taps** | 向量 | FIR 滤波器系数 | [] |
| **Sample Delay** | 整数 | 样本延迟（用于标签调整） | 0 |

## 参数说明

**1. Type（数据类型）**
- **Complex->Complex (Complex Taps)**：复数输入输出，复数系数
- **Complex->Complex (Real Taps)**：复数输入输出，实数系数
- **Float->Float (Real Taps)**：实数输入输出，实数系数
- **Float->Complex (Complex Taps)**：实数输入，复数输出

**2. Decimation（抽取因子）**
- 降采样倍数
- 输出采样率 = 输入采样率 / Decimation
- 必须是正整数
- Decimation = 1：只滤波，不降采样
- Decimation > 1：滤波并降采样

**3. Taps（滤波器系数）**
- FIR 滤波器的系数向量
- 使用 firdes 或其他工具设计
- 必须设计为抗混叠滤波器
- 截止频率应 < (输入采样率 / (2 × Decimation))

**4. Sample Delay（样本延迟）**
- 用于调整流标签的位置
- 补偿滤波器的群延迟
- 通常设为 0，让系统自动处理
- 高级应用中手动调整标签位置

## 工作原理

**处理流程：**
```
输入 (fs) → FIR 滤波 → 抽取 (÷D) → 输出 (fs/D)
```

**抗混叠滤波：**

降采样前必须滤除高频分量以防止混叠：
```
截止频率 ≤ (输入采样率) / (2 × Decimation)
```

**效率优势：**

集成实现只需计算输出样本对应的滤波器输出，跳过被丢弃的样本：
```
平均每个输入样本的乘加量约为 抽头数 / Decimation
```

只计算需要保留的滤波输出，可减少不必要的运算；实际加速取决于系数长度、类型和实现。

**实现方式：**

直接计算所需的抽取相位，每次 FIR 计算后按 Decimation 跨过输入；不必计算随后要丢弃的全部输出。

## 快速示例

**示例 1：音频降采样（48kHz → 8kHz）**

```
[Audio Source] → [Decimating FIR Filter] → [Processing]
  (48kHz)         (decim=6, LPF 3.5kHz)     (8kHz)
```

配置参数：
- Type: Float->Float (Real Taps)
- Decimation: 6
- Taps: taps
- Sample Delay: 0

**示例 2：目标频带提取（2MHz → 200kHz）**

```python
samp_rate = 2000000
decimation = 10
cutoff = 90000  # 90 kHz
transition = 20000

taps = firdes.low_pass(
    1.0,
    samp_rate,
    cutoff,
    transition
)
```

```
[Acquisition Source] → [Decimating FIR Filter] → [Analysis]
  (2MHz)         (decim=10, LPF 90kHz)     (200kHz)
```

配置参数：
- Type: Complex->Complex (Real Taps)
- Decimation: 10
- Taps: taps

**示例 3：多级降采样**

```
[Source] → [Decim FIR 1] → [Decim FIR 2] → [Output]
  (1MHz)    (÷5, 200kHz)    (÷4, 50kHz)     (50kHz)
```

使用多级降采样可以获得更好的滤波器性能和效率。

**示例 4：宽带信号处理**

```python
# 从 10 MHz 宽带中提取 100 kHz 目标频带
samp_rate = 10000000
decimation = 100
cutoff = 45000
transition = 10000

taps = firdes.low_pass(1.0, samp_rate, cutoff, transition)
```

```
[Wideband Input] → [Decimating FIR] → [Narrowband Processing]
  (10MHz)        (÷100, 45kHz LPF)  (100kHz)
```

## 滤波器设计指南

**截止频率选择：**
```
f_cutoff ≤ (f_input / (2 × Decimation)) - f_transition/2

例如：
输入采样率 = 48 kHz
Decimation = 6
输出 Nyquist = 48000/(2×6) = 4000 Hz
截止频率 ≤ 3500 Hz（留出过渡带）
```

**过渡带宽度：**
- 越窄需要更多系数
- 典型值：截止频率的 10-20%

**滤波器长度估算：**
```
N ≈ (Attenuation_dB × f_sample) / (22 × f_transition)

例如：
阻带衰减 = 60 dB
采样率 = 48 kHz
过渡带 = 500 Hz
N ≈ (60 × 48000) / (22 × 500) ≈ 261 taps
```

## 性能与部署

1. **计算效率**  
   - 避免计算随后被抽取丢弃的输出；实际性能应测量
   - 每个输出仍需对相应的抽头进行运算

2. **内存使用**  
   - 需要存储滤波器系数
   - 需要延迟线缓冲区

3. **延迟**  
   - 群延迟 = (N-1) / (2 × 输出采样率)
   - N 是滤波器长度

4. **混叠风险**  
   - 必须正确设计抗混叠滤波器
   - 截止频率不能太高

## 故障排查

**Q1: Decimation 为 1 时有什么用？**  
A: 只进行滤波，不降采样。等效于普通 FIR Filter。

**Q2: 如何避免混叠？**  
A: 确保滤波器截止频率 < (输入采样率 / (2 × Decimation))。

**Q3: 可以任意设置 Decimation 吗？**  
A: 可以，但大的 Decimation 因子需要更陡峭的滤波器。考虑使用多级降采样。

**Q4: 如何选择滤波器长度？**  
A: 根据所需的阻带衰减和过渡带宽度。使用 firdes 自动计算。

**Q5: 与 Rational Resampler 有什么区别？**  
A: Decimating FIR 只降采样（Decimation > 1）。Rational Resampler 可以升采样、降采样或两者结合。

**Q6: Sample Delay 参数何时使用？**  
A: 通常保持为 0。只在需要精确控制流标签位置时手动设置。

**Q7: 多级降采样有什么优势？**  
A: 每级使用较小的 Decimation 因子，滤波器设计更容易，总体效率更高。

## 多级降采样设计

**单级 vs 多级：**

单级降采样 100 倍：
```
[Input] → [Decim FIR ÷100] → [Output]
          (需要很陡峭的滤波器)
```

多级降采样 100 倍：
```
[Input] → [Decim ÷10] → [Decim ÷10] → [Output]
          (两个较缓的滤波器)
```

**优势：**
- 每级滤波器更简单
- 总计算量更少
- 更容易设计和调试

**设计原则：**
- 将大的 Decimation 因子分解为较小因子的乘积
- 例如：100 = 10 × 10 或 5 × 5 × 4
- 优先使用 2、3、5 等小因子

## 典型应用场景

**高采样率传感器采集：**
```
[ADC 10MHz] → [Decim ÷50] → [Analysis] → [Output]
                (200kHz)
```

**音频处理：**
```
[Audio 48kHz] → [Decim ÷6] → [Processing] → [Interp ×6] → [Audio 48kHz]
                 (8kHz)                       (8kHz)
```

**频谱分析：**
```
[Wideband] → [Decim] → [FFT] → [Display]
              (降低FFT负担)
```

**多速率滤波器组：**
```
[Input] → [Decim ÷M₁] → [Band 1]
        → [Decim ÷M₂] → [Band 2]
        → [Decim ÷M₃] → [Band 3]
```

## 相关 Block

- [Interpolating FIR Filter](Interpolating_FIR_Filter.md)：插值 FIR 滤波器（升采样）
- [Rational Resampler](Rational_Resampler.md)：有理数重采样
- [Low Pass Filter](Low_Pass_Filter.md)：普通低通滤波器
- [Polyphase Arbitrary Resampler](Polyphase_Arbitrary_Resampler.md)：任意倍率重采样

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
