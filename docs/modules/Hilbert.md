# Hilbert 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Hilbert

## 概览

Hilbert 模块实现希尔伯特变换，将实数信号转换为解析信号（analytic signal）。它输出复数信号，其中实部是经过适当延迟的输入信号，虚部是输入信号的希尔伯特变换（90度相移版本）。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Filters（滤波器） |
| Block ID | `hilbert_fc` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **生成解析信号**  
   将实数信号转换为复数解析信号

2. **正交信号构造**  
   生成相差 90 度的分量用于解析信号分析

3. **瞬时频率估计**  
   计算信号的瞬时频率和瞬时相位

4. **包络检测**  
   提取信号的包络信息

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | `float` | 连续样本流端口 |
| 输出 | `默认` | 样本流 | `complex` | 连续样本流端口 |

> 滤波设计采样率应与系数作用的处理段一致；抽取型按抽取前、插值型按插值后采样率设计，并用已知信号验证频响。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Num Taps** | 整数 | 设置滤波器抽头数量 | 65 | ✗ |
| **Window** | 枚举 | 选择 FFT 窗函数 | Hamming | ✗ |
| **Beta** | 浮点数 | 设置窗函数形状参数；仅对支持 Beta 的窗函数生效 | 6.76 | ✗ |

## 参数说明

**1. Num Taps**
- 滤波器抽头数

**2. Window**
- 窗函数类型
  - **Hamming**：window.WIN_HAMMING
  - **Hann**：window.WIN_HANN
  - **Blackman**：window.WIN_BLACKMAN
  - **Blackman-harris**：window.WIN_BLACKMAN_hARRIS
  - **Rectangular**：window.WIN_RECTANGULAR
  - **Kaiser**：window.WIN_KAISER

**3. Beta**
- Beta 参数

## 工作原理

**希尔伯特变换定义：**

希尔伯特变换对信号进行 90 度相移：
```
H{x(t)} = x(t) * (1/πt)
```

**解析信号：**
```
z(t) = x(t) + j·H{x(t)}

其中：
- x(t)：原始实数信号
- H{x(t)}：希尔伯特变换
- z(t)：解析信号（复数）
```

**输出：**
- 实部：输入信号的延迟版本（补偿滤波器延迟）
- 虚部：输入信号的希尔伯特变换（90度相移）

**频域特性：**
```
正频率：幅度 ×2
负频率：幅度 = 0
```

解析信号只包含正频率分量。

## 快速示例

**示例 1：生成解析信号**

```
[Audio Source] → [Hilbert] → [Complex to Mag] → [QT GUI Time Sink]
  (real)          (analytic)   (envelope)
```

配置参数：
- Num Taps: 65
- Window: Hamming
- Beta: 6.76

**示例 2：正交分析信号构造**

```
[Sensor Signal] → [Hilbert] → [Complex to Mag] → [Envelope]
  (input)          (analytic)       (幅值)
```

配置参数：
- Num Taps: 129
- Window: Blackman

**示例 3：包络检测**

```
[AM Signal] → [Hilbert] → [Complex to Mag] → [Audio Sink]
  (real)       (analytic)   (envelope)
```

配置参数：
- Num Taps: 65
- Window: Hamming

**示例 4：瞬时频率估计**

```
[Signal] → [Hilbert] → [Complex to Arg] → [Differentiate] → [Frequency Display]
            (analytic)   (phase)           (inst. freq)
```

## 数学背景

**解析信号的性质：**

1. **单边频谱**  
   解析信号只有正频率分量，负频率为零

2. **包络和相位**  
   ```
   z(t) = A(t)·e^(jφ(t))
   A(t) = |z(t)| = 包络
   φ(t) = arg(z(t)) = 瞬时相位
   ```

3. **瞬时频率**  
   ```
   f_inst(t) = (1/2π)·dφ(t)/dt
   ```

**希尔伯特变换的性质：**
- 线性变换
- 时不变
- 能量守恒
- 90度相移

## 滤波器设计

**FIR 近似：**

理想希尔伯特变换器的冲激响应：
```
h(n) = (2/π) · sin²(πn/2) / n,  n ≠ 0
h(0) = 0
```

实际实现使用窗函数法设计有限长度的 FIR 滤波器。

**延迟补偿：**

滤波器引入的群延迟：
```
delay = (Num_Taps - 1) / 2 样本
```

实部输出经过相同延迟以保持时间对齐。

## 性能与部署

1. **滤波器长度**  
   - 更长的滤波器提供更好的性能
   - 但增加计算复杂度和延迟
   - 推荐：65-129 taps

2. **窗函数选择**  
   - Hamming：通用选择，性能良好
   - Blackman：需要更好性能时使用
   - Kaiser：需要精确控制时使用

3. **计算复杂度**  
   每个输出样本需要 Num_Taps 次乘加运算

4. **内存使用**  
   需要 Num_Taps 个样本的延迟线

## 故障排查

**Q1: 为什么需要希尔伯特变换？**  
A: 将实数信号转换为解析信号，便于提取包络、相位和瞬时频率等信息。

**Q2: 输出为什么是复数？**  
A: 解析信号本质上是复数，实部是原信号，虚部是 90 度相移版本。

**Q3: Num Taps 如何选择？**  
A: 通常 65 或 129。更大的值提供更好的性能但增加延迟。必须是奇数。

**Q4: 可以用于复数信号吗？**  
A: 不可以，Hilbert 模块只接受实数输入。复数信号已经是解析信号。

**Q5: 如何验证希尔伯特变换的正确性？**  
A: 检查输出的实部和虚部是否正交（相关性接近零），或查看频谱是否只有正频率。

**Q6: 延迟有多大？**  
A: 群延迟 = (Num_Taps - 1) / 2 个样本。例如 Num_Taps=65 时，延迟 32 个样本。

## 应用场景

**1. 解析信号构造**
```
[Sensor Signal] → [Hilbert] → [Complex Analysis]
```

**2. 包络检测**
```
[AM Signal] → [Hilbert] → [Complex to Mag] → [Envelope]
```

**3. 瞬时频率分析**
```
[Signal] → [Hilbert] → [Phase] → [Differentiate] → [Inst. Freq]
```

**4. 瞬时频率提取**
```
[Vibration Signal] → [Hilbert] → [Complex to Arg] → [Differentiate] → [Inst. Freq]
```

## 窗函数性能对比

| 窗函数 | 旁瓣抑制 | 过渡带 | 适用场景 |
|--------|---------|--------|---------|
| Hamming | -43 dB | 中等 | 通用，推荐 |
| Hann | -31 dB | 中等 | 通用 |
| Blackman | -58 dB | 宽 | 高性能要求 |
| Rectangular | -13 dB | 窄 | 不推荐 |
| Kaiser | 可调 | 可调 | 灵活应用 |
| Blackman-Harris | -92 dB | 很宽 | 极高性能要求 |

## 相关 Block

- [Complex to Mag](Complex_to_Mag.md)：计算解析信号的幅度（包络）
- **Complex to Arg**：计算解析信号的相位
- [Frequency Shift](Frequency_Shift.md)：频带搬移
- [Single Pole IIR Filter](Single_Pole_IIR_Filter.md)：简单的相位调整

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
