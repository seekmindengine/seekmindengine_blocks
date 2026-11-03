# Polyphase Arbitrary Resampler 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Polyphase Arbitrary Resampler

## 概览

Polyphase Arbitrary Resampler 模块实现任意比例的采样率转换，使用多相滤波器结构提供高质量的重采样。它可以处理任意的非整数重采样比率，适用于需要精确采样率转换的应用。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Resamplers（重采样器） |
| Block ID | `pfb_arb_resampler_xxx` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **任意采样率转换**  
   实现任意比例的采样率变换

2. **符号定时恢复**  
   调整采样相位以恢复符号定时

3. **采样率匹配**  
   匹配不同设备的采样率

4. **信号重采样**  
   高质量的信号插值和抽取

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
| **Resampling Rate** | 浮点数 | 设置输出与输入采样率之比 |  | ✓ |
| **Taps** | 类型相关 | 设置滤波器抽头系数 |  | ✓ |
| **Number of Filters** | 整数 | 设置多相滤波器的支路数量 | 32 | ✗ |
| **Stop-band Attenuation** | 浮点数 | 设置阻带衰减目标，单位为 dB | 100 | ✗ |
| **Sample Delay** | 整数 | 设置样本延迟量 | 0 | ✗ |

## 参数说明

**1. Type**
- 数据类型
  - **Complex->Complex (Real Taps)**：ccf
  - **Float->Float (Real Taps)**：fff
  - **Complex->Complex (Complex Taps)**：ccc

**2. Resampling Rate**
- 重采样率

**3. Taps**
- 滤波器抽头系数

**4. Number of Filters**
- 滤波器数量

**5. Stop-band Attenuation**
- 阻带衰减目标，数值越高通常需要更多滤波器抽头。
**6. Sample Delay**
- 采样延迟

## 工作原理

**多相重采样原理：**

```
输入信号 → 多相滤波器组 → 插值 → 输出信号
           ↓
        Filter_Size 个分支
           ↓
        根据相位选择分支
           ↓
        计算输出样本
```

**重采样过程：**

1. **上采样（Resample Rate > 1）：**
   ```
   输入：  ●───●───●───●
   输出：  ●─●─●─●─●─●─●─●
   
   例如：Rate = 2.0
   输出采样率 = 2 × 输入采样率
   ```

2. **下采样（Resample Rate < 1）：**
   ```
   输入：  ●─●─●─●─●─●─●─●
   输出：  ●───●───●───●
   
   例如：Rate = 0.5
   输出采样率 = 0.5 × 输入采样率
   ```

3. **任意比率（例如 Rate = 1.5）：**
   ```
   输入：  ●───●───●───●
   输出：  ●─●──●─●──●─●
   ```

**多相滤波器结构：**

```
原型滤波器 h[n] → 分解为 Filter_Size 个子滤波器

h₀[n] = h[0], h[Filter_Size], h[2×Filter_Size], ...
h₁[n] = h[1], h[Filter_Size+1], h[2×Filter_Size+1], ...
...
h_{Filter_Size-1}[n] = h[Filter_Size-1], ...

根据输出相位选择相应的子滤波器
```

**相位计算：**
```
output_phase = (input_index × Resample_Rate) mod 1.0
filter_branch = floor(output_phase × Filter_Size)
```

## 快速示例

**示例 1：基本重采样**

```
[Signal Source] → [Polyphase Arbitrary Resampler] → [Output]
  (32 kHz)         (Rate = 1.5)                       (48 kHz)
```

配置参数：
- Type: Complex
- Resample Rate: 1.5
- Filter Size: 32

**示例 2：符号定时恢复**

```
[Matched Filter] → [Polyphase Arbitrary Resampler] → [Symbol Slicer]
                    (Rate ≈ 1.0, 微调)
```

配置参数：
- Resample Rate: 1.0001  (微调)
- 用于补偿定时漂移

**示例 3：采样率匹配**

```
[Audio Source] → [Polyphase Arbitrary Resampler] → [Audio Sink]
  (44.1 kHz)      (Rate = 48/44.1 ≈ 1.088)           (48 kHz)
```

配置参数：
- Resample Rate: 1.08843537
- 音频采样率转换

**示例 4：采集数据采样率调整**

```
[Acquisition Source] → [Polyphase Arbitrary Resampler] → [Processing]
  (2 MHz)        (Rate = 1.25)                       (2.5 MHz)
```

配置参数：
- Type: Complex
- Resample Rate: 1.25
- Filter Size: 32

**示例 5：动态重采样**

```python
# 可以动态改变重采样比率
resampler.set_rate(new_rate)
```

用于自适应采样率转换。

## 滤波器设计

**原型滤波器设计原则：**

1. **截止频率：**
   ```
   fc = min(0.5 / Resample_Rate, 0.5)
   
   例如：
   Rate = 2.0 → fc = 0.25 (防止混叠)
   Rate = 0.5 → fc = 0.5 (保留带宽)
   ```

2. **滤波器长度：**
   ```
   N_taps = Filter_Size × M
   
   其中 M 是每个分支的抽头数
   典型值：M = 11 到 21
   ```

3. **窗函数选择：**
   - Hamming：通用
   - Blackman：低旁瓣
   - Kaiser：可调参数

**设计示例：**

## 性能与部署

1. **计算复杂度**  
   - 每个输出样本需要约 N_taps / Filter_Size 次乘加
   - 与 Resample Rate 成正比
   - 推荐 Filter Size：16 - 64

2. **滤波器质量**  
   - 更大的 Filter Size 提供更好的质量
   - 更多的 Taps 提供更好的频率响应
   - 权衡：质量 vs 计算量

3. **延迟**  
   - 群延迟 ≈ N_taps / (2 × Filter_Size)
   - 对于实时应用需要考虑

4. **内存使用**  
   - 需要存储所有滤波器系数
   - 内存 = N_taps × sizeof(float)

## 故障排查

**Q1: 与 Rational Resampler 有什么区别？**  
A: 
- Rational Resampler：整数比率（L/M）
- Polyphase Arbitrary Resampler：任意比率
- Arbitrary 更灵活但稍慢

**Q2: 如何选择 Filter Size？**  
A: 
- 一般应用：32
- 高质量：64
- 低延迟：16

**Q3: 可以动态改变重采样比率吗？**  
A: 可以，使用 `set_rate()` 方法。

**Q4: 如何设计滤波器系数？**  
A: 使用 firdes.low_pass()，截止频率设为 min(0.5/Rate, 0.5)。

**Q5: 输出采样率如何计算？**  
A: Output_Rate = Input_Rate × Resample_Rate

**Q6: 有延迟吗？**  
A: 有，群延迟约为滤波器长度的一半。

**Q7: 适合实时应用吗？**  
A: 适合，但要注意延迟和计算负载。

## 与其他重采样器对比

| 模块 | 比率类型 | 质量 | 复杂度 | 适用场景 |
|------|---------|------|--------|---------|
| Rational Resampler | 整数比 L/M | 高 | 中 | 固定整数比 |
| Fractional Resampler | 任意 | 中 | 低 | 接近 1.0 的比率 |
| Polyphase Arbitrary | 任意 | 高 | 高 | 任意比率，高质量 |

**选择建议：**
- **整数比率**：Rational Resampler
- **接近 1.0**：Fractional Resampler
- **任意比率 + 高质量**：Polyphase Arbitrary Resampler

## 实际应用案例

**案例 1：音频采样率转换**

```
[Audio File] → [Polyphase Arbitrary Resampler] → [Audio Sink]
  (44.1 kHz)    (Rate = 48/44.1)                  (48 kHz)
```

配置：
- Resample Rate: 1.08843537
- Filter Size: 32
- 高质量音频转换

**案例 2：符号定时恢复**

```
[Matched Filter] → [Polyphase Arbitrary Resampler] → [Clock Recovery]
                    (微调采样相位)
```

配置：
- Resample Rate: 1.0 ± δ
- 动态调整以锁定符号定时

**案例 3：嵌入式采集采样率适配**

```
[Acquisition Node] → [Polyphase Arbitrary Resampler] → [Detector]
  (2.048 MHz)  (Rate = 2.5/2.048)                (2.5 MHz)
```

配置：
- Resample Rate: 1.220703125
- 匹配检测算法要求的采样率

**案例 4：多速率信号处理**

```
[Input] → [Polyphase Arbitrary Resampler] → [Processing] → [Polyphase Arbitrary Resampler] → [Output]
          (Rate = R1)                                       (Rate = 1/R1)
```

在不同采样率下处理信号。

## 典型应用场景

**采样率转换：**
```
[Source] → [Polyphase Arbitrary Resampler] → [Sink]
           (任意比率转换)
```

**定时恢复：**
```
[Signal] → [Polyphase Arbitrary Resampler] → [Symbol Sync]
           (相位调整)
```

**多速率处理：**
```
[Input] → [Resample] → [Process] → [Resample] → [Output]
          (变速率)                  (恢复)
```

**设备适配：**
```
[Device A] → [Polyphase Arbitrary Resampler] → [Device B]
             (采样率匹配)
```

## 相关 Block

- [Rational Resampler](Rational_Resampler.md)：整数比率重采样
- **Fractional Resampler**：分数重采样
- **Polyphase Clock Sync**：符号定时恢复
- **FIR Filter**：基本 FIR 滤波

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
