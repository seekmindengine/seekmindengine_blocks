# Interpolating FIR Filter 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Interpolating FIR Filter

## 概览

Interpolating FIR Filter 结合了升采样（插值）和 FIR 滤波操作。它先将信号升采样（插入零值），然后进行滤波以平滑信号并去除镜像频谱。这种集成实现比分别使用插值器和滤波器更高效。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Filters（滤波器） |
| Block ID | `interp_fir_filter_xxx` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **升采样**  
   提高信号的采样率

2. **输出设备前端**  
   为 DAC 或激励输出设备准备高采样率信号

3. **多速率信号处理**  
   实现多速率滤波器组

4. **信号重建**  
   从低采样率重建高采样率信号

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
| **Interpolation** | 整数 | 设置插值倍数；输出速率为输入速率乘以该值 | 1 | ✗ |
| **Taps** | 类型相关 | 设置滤波器抽头系数 |  | ✓ |
| **Sample Delay** | 整数 | 声明用于标签位置调整的样本延时 | 0 | ✗ |

## 参数说明

**1. Type**
- 数据类型
  - **Complex->Complex (Complex Taps)**：ccc
  - **Complex->Complex (Real Taps)**：ccf
  - **Float->Complex (Complex Taps)**：fcc
  - **Float->Float (Real Taps)**：fff
  - **Float->Short (Real Taps)**：fsf
  - **Short->Complex (Complex Taps)**：scc

**2. Interpolation**
- 内插因子

**3. Taps**
- 滤波器抽头系数

**4. Sample Delay**
- 用于标签位置调整的延时声明；不额外插入 Delay 样本

## 工作原理

**处理流程：**
```
输入 (fs) → 插值 (×I) → FIR 滤波 → 输出 (fs×I)
           (插入零值)   (去除镜像)
```

**插值过程：**

1. **零值插入：**
   ```
   输入: [x₀, x₁, x₂, ...]
   插值后: [x₀, 0, 0, ..., x₁, 0, 0, ..., x₂, ...]
           └─ I-1个零 ─┘
   ```

2. **镜像频谱：**
   插值后的信号在频域产生镜像，需要滤波去除

3. **低通滤波：**
   ```
   截止频率 = (输入采样率) / 2
   ```

**效率优势：**

集成实现利用零值的特性，只计算非零输入对应的滤波器输出：
```
每个输出样本的乘加量约为 ceil(抽头数 / Interpolation)
```

多相实现可避免显式处理插入的零值；实际加速取决于系数长度、类型和实现。

**多相实现：**

内部使用多相滤波器结构，进一步提高效率。

## 快速示例

**示例 1：音频升采样（8kHz → 48kHz）**

```
[Audio Source] → [Interpolating FIR Filter] → [Audio Sink]
  (8kHz)          (interp=6, LPF 3.5kHz)      (48kHz)
```

配置参数：
- Type: Float->Float (Real Taps)
- Interpolation: 6
- Taps: taps
- Sample Delay: 0

**示例 2：输出设备前端（200kHz → 2MHz）**

```python
input_rate = 200000
interpolation = 10
cutoff = 90000  # 低于 100 kHz (Nyquist)
transition = 20000

taps = firdes.low_pass(
    interpolation,
    input_rate * interpolation,
    cutoff,
    transition
)
```

```
[Input Signal] → [Interpolating FIR] → [Output Device]
  (200kHz)           (×10, LPF 90kHz)      (2MHz)
```

配置参数：
- Type: Complex->Complex (Real Taps)
- Interpolation: 10
- Taps: taps

**示例 3：多级升采样**

```
[Source] → [Interp FIR 1] → [Interp FIR 2] → [Output]
  (50kHz)   (×4, 200kHz)     (×5, 1MHz)       (1MHz)
```

使用多级升采样可以获得更好的滤波器性能和效率。

**示例 4：符号成形**

```python
# 编码波形成形示例
samples_per_symbol = 4
symbol_rate = 1000
output_rate = symbol_rate * samples_per_symbol

# 根升余弦滤波器
taps = firdes.root_raised_cosine(
    samples_per_symbol,  # gain
    output_rate,         # 输出采样率
    symbol_rate,         # 符号率
    0.35,               # 滚降因子
    11 * samples_per_symbol  # 滤波器长度
)
```

```
[Symbol Source] → [Interpolating FIR] → [Waveform Mapper]
  (1k symbols/s)   (×4, RRC filter)     (4k samples/s)
```

## 滤波器设计指南

**增益设置：**
```
Gain = Interpolation

原因：插值后信号幅度降低 Interpolation 倍
滤波器增益补偿这个衰减
```

**截止频率选择：**
```
f_cutoff ≤ (f_input / 2) - f_transition/2

例如：
输入采样率 = 8 kHz
输入 Nyquist = 4 kHz
截止频率 ≤ 3.5 kHz（留出过渡带）
```

**采样率参数：**

在 firdes 中使用输出采样率：
```python
taps = firdes.low_pass(
    interpolation,              # gain
    input_rate * interpolation, # 输出采样率！
    cutoff,
    transition
)
```

**滤波器长度：**

与 Decimating FIR 类似，根据所需的阻带衰减和过渡带确定。

## 性能与部署

1. **计算效率**  
   - 多相实现减少零值运算，实际性能应测量
   - 使用多相结构优化

2. **内存使用**  
   - 需要存储滤波器系数
   - 需要延迟线缓冲区

3. **延迟**  
   - 群延迟 = (N-1) / (2 × 输出采样率)
   - N 是滤波器长度

4. **镜像抑制**  
   - 滤波器必须充分抑制镜像频谱
   - 阻带衰减要足够大

## 故障排查

**Q1: 为什么增益要设为 Interpolation？**  
A: 插值插入零值后，信号能量分散，幅度降低。增益补偿这个衰减。

**Q2: Interpolation 为 1 时有什么用？**  
A: 只进行滤波，不升采样。等效于普通 FIR Filter。

**Q3: 如何避免镜像频谱？**  
A: 使用足够陡峭的低通滤波器，截止频率 < 输入 Nyquist 频率。

**Q4: firdes 的采样率参数用哪个？**  
A: 使用输出采样率（input_rate × interpolation）。

**Q5: 与 Rational Resampler 有什么区别？**  
A: Interpolating FIR 只升采样。Rational Resampler 可以升采样、降采样或两者结合。

**Q6: 多级升采样有什么优势？**  
A: 每级使用较小的 Interpolation 因子，滤波器设计更容易，总体效率更高。

**Q7: 可以用于符号成形吗？**  
A: 可以，使用根升余弦等成形滤波器作为 Taps。

## 多级升采样设计

**单级 vs 多级：**

单级升采样 100 倍：
```
[Input] → [Interp FIR ×100] → [Output]
          (需要很陡峭的滤波器)
```

多级升采样 100 倍：
```
[Input] → [Interp ×10] → [Interp ×10] → [Output]
          (两个较缓的滤波器)
```

**优势：**
- 每级滤波器更简单
- 总计算量更少
- 更容易设计和调试

**设计原则：**
- 将大的 Interpolation 因子分解为较小因子的乘积
- 例如：100 = 10 × 10 或 5 × 5 × 4
- 优先使用 2、3、5 等小因子

## 典型应用场景

**编码波形输出：**
```
[Symbols] → [Interp FIR] → [Frequency Shift] → [Output Node]
  (符号率)   (成形滤波)      (上变频)
```

**音频升采样：**
```
[Audio 8kHz] → [Interp ×6] → [Processing] → [Audio Sink]
                (48kHz)                      (48kHz)
```

**DAC 前端：**
```
[Baseband] → [Interp] → [DAC]
              (提高采样率)
```

**多速率滤波器组：**
```
[Band 1] → [Interp ×M₁] →
[Band 2] → [Interp ×M₂] → [Add] → [Output]
[Band 3] → [Interp ×M₃] →
```

## 符号成形应用

**BPSK/QPSK 编码波形成形：**

```python
# 参数
symbol_rate = 1000
sps = 4  # samples per symbol
rolloff = 0.35

# 根升余弦滤波器
taps = firdes.root_raised_cosine(
    sps,                    # gain
    symbol_rate * sps,      # 输出采样率
    symbol_rate,            # 符号率
    rolloff,                # 滚降因子
    11 * sps                # 滤波器长度
)
```

```
[Symbols] → [Interpolating FIR] → [Waveform Mapper]
  (±1)       (RRC, ×4)             (shaped)
```

**优势：**
- 限制带宽
- 减少符号间干扰（ISI）
- 匹配滤波（输入端使用相同滤波器）

## 相关 Block

- [Decimating FIR Filter](Decimating_FIR_Filter.md)：抽取 FIR 滤波器（降采样）
- [Rational Resampler](Rational_Resampler.md)：有理数重采样
- [Root Raised Cosine Filter](Root_Raised_Cosine_Filter.md)：根升余弦滤波器
- [Polyphase Arbitrary Resampler](Polyphase_Arbitrary_Resampler.md)：任意倍率重采样

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
