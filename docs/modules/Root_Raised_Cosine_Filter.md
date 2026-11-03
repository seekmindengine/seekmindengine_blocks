# Root Raised Cosine Filter 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Root Raised Cosine Filter

## 概览

Root Raised Cosine (RRC) Filter 是数字链路实验中常用的脉冲成形滤波器之一。它可用于水声数字传输或编码波形验证中的匹配滤波，比普通低通滤波器、静噪或其他模块更有效地从噪声中提取已知的数字信号。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Filters（滤波器） |
| Block ID | `root_raised_cosine_filter` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **脉冲成形**  
   在输出端对符号进行成形，限制带宽

2. **匹配滤波**  
   在输入端进行匹配滤波，最大化信噪比

3. **符号间干扰控制**  
   最小化符号间干扰（ISI）

4. **数字编码波形**  
   PSK、QAM 等符号映射方式的标准滤波器

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | 由数据类型参数决定 | 连续样本流端口 |
| 输出 | `默认` | 样本流 | 由数据类型参数决定 | 连续样本流端口 |

> 滤波设计采样率应与系数作用的处理段一致；抽取型按抽取前、插值型按插值后采样率设计，并用已知信号验证频响。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **FIR Type** | 枚举 | 选择滤波器输入输出的数据类型组合 | Complex->Complex (Decimating) | ✗ |
| **Decimation** | 整数 | 设置抽取倍数；输出速率为输入速率除以该值 | 1 | ✗ |
| **Interpolation** | 整数 | 设置插值倍数；输出速率为输入速率乘以该值 | 1 | ✗ |
| **Gain** | 浮点数 | 设置线性增益系数 | 1 | ✓ |
| **Sample Rate** | 浮点数 | 设置采样率，单位为 Sps | 1e6 | ✓ |
| **Symbol Rate** | 浮点数 | 设置符号率，单位为 symbols/s | 500e3 | ✓ |
| **Alpha** | 浮点数 | 设置算法平滑或滚降系数，取值约束见对应工作原理 | 0.35 | ✓ |
| **Num Taps** | 整数 | 设置滤波器抽头数量 | 64 | ✓ |

## 参数说明

**1. FIR Type**
- FIR 滤波器类型
  - **Complex->Complex (Decimating)**：fir_filter_ccf
  - **Complex->Complex (Interpolating)**：interp_fir_filter_ccf
  - **Float->Float (Decimating)**：fir_filter_fff
  - **Float->Float (Interpolating)**：interp_fir_filter_fff

**2. Decimation**
- 抽取因子

**3. Interpolation**
- 内插因子

**4. Gain**
- 增益

**5. Sample Rate**
- 采样率（Hz）

**6. Symbol Rate**
- 符号速率

**7. Alpha**
- Alpha 参数

**8. Num Taps**
- 滤波器抽头数

Num Taps 最终会调整为奇数，偶数请求值增加 1；按实际系数长度计算群延时。

## 工作原理

**根升余弦函数：**

时域表达式：
```
h(t) = (sin(π·t/T·(1-α)) + 4α·t/T·cos(π·t/T·(1+α))) / (π·t/T·(1-(4α·t/T)²))

其中：
- T = 符号周期 = 1/Symbol_Rate
- α = 滚降因子（Excess BW）
- t = 时间
```

**频域特性：**

```
         ┌─────┐
    1.0  │     │╲
         │     │ ╲
         │     │  ╲
    0.5  │     │   ╲
         │     │    ╲___
         └─────┴────────→ f
         0   (1-α)/2T  (1+α)/2T
```

**带宽：**
```
BW = Symbol_Rate × (1 + α)

例如：
Symbol_Rate = 1000 baud
α = 0.35
BW = 1000 × 1.35 = 1350 Hz
```

**匹配滤波特性：**

输出端和输入端都使用 RRC 滤波器时：
```
H_total(f) = H_tx(f) × H_rx(f) = H_RC(f)
```

总响应是升余弦（Raised Cosine），满足 Nyquist 准则，无 ISI。

## 快速示例

**示例 1：BPSK 输出端**

```
[Symbol Source] → [RRC Filter] → [Frequency Shift] → [Output Node]
  (±1, 1k baud)    (成形)         (上变频)
```

配置参数：
- Sample Rate: 32000
- Symbol Rate: 1000
- Excess BW: 0.35
- Num Taps: 352 (11×32)
- Gain: 1.0

**示例 2：QPSK 输入端**

```
[Complex Sample Source] → [Frequency Shift] → [RRC Filter] → [Symbol Sync] → [Symbol Detector]
                 (下变频)            (匹配滤波)     (定时恢复)
```

配置参数：
- Sample Rate: 32000
- Symbol Rate: 1000
- Excess BW: 0.35  (与输出端相同)
- Num Taps: 352
- Decimation: 1  (或 sps 用于符号同步)

**示例 3：完整的水声数字链路**

输出端：
```
[Data] → [Pack K Bits] → [Constellation] → [RRC Output] → [Propagation]
         (打包)           (映射)            (成形)
```

输入端：
```
[Propagation] → [RRC Input] → [Clock Recovery] → [Constellation] → [Unpack] → [Data]
             (匹配)     (定时恢复)         (解映射)         (解包)
```

**示例 4：不同滚降因子的比较**

```python
# α = 0.2 (窄带宽)
taps_02 = firdes.root_raised_cosine(1.0, samp_rate, symbol_rate, 0.2, num_taps)

# α = 0.35 (标准)
taps_035 = firdes.root_raised_cosine(1.0, samp_rate, symbol_rate, 0.35, num_taps)

# α = 0.5 (宽带宽)
taps_05 = firdes.root_raised_cosine(1.0, samp_rate, symbol_rate, 0.5, num_taps)
```

## 滚降因子的影响

| α值 | 带宽 | 时域衰减 | ISI 容限 | 适用场景 |
|-----|------|---------|---------|---------|
| 0.2 | 窄 | 慢 | 低 | 带宽受限 |
| 0.35 | 中等 | 中等 | 中等 | 通用（推荐） |
| 0.5 | 宽 | 快 | 高 | 定时误差大 |
| 1.0 | 很宽 | 很快 | 很高 | 特殊应用 |

**权衡：**
- **小 α**：带宽效率高，但对定时误差敏感
- **大 α**：定时容限大，但占用更多带宽

## 匹配滤波原理

**输出端：**
```
符号 → RRC 滤波器 → 成形信号
```

**传播环境：**
```
成形信号 + 噪声 → 输入信号
```

**输入端：**
```
输入信号 → RRC 滤波器 → 最大 SNR
```

**数学原理：**

匹配滤波器最大化输出信噪比：
```
SNR_out = 2·E_s / N_0

其中：
- E_s = 符号能量
- N_0 = 噪声功率谱密度
```

**总响应：**
```
H_total(f) = H_RRC_tx(f) × H_RRC_rx(f) = H_RC(f)
```

升余弦响应满足 Nyquist 第一准则，在采样时刻无 ISI。

## 性能与部署

1. **滤波器长度**  
   - 更长的滤波器提供更好的频谱成形
   - 但增加延迟和计算复杂度
   - 推荐：11 × sps

2. **群延迟**  
   ```
   delay = (Num_Taps - 1) / (2 × Sample_Rate)
   ```

3. **计算复杂度**  
   - 每个输出样本需要 Num_Taps 次乘加
   - 使用多相结构可以优化

4. **内存使用**  
   - 需要存储 Num_Taps 个系数
   - 需要延迟线缓冲区

## 故障排查

**Q1: RRC 和 RC 有什么区别？**  
A: RRC 是 RC 的平方根。输出端和输入端都用 RRC，总响应是 RC。

**Q2: 为什么要用匹配滤波？**  
A: 匹配滤波器在加性高斯白噪声环境中最大化信噪比。

**Q3: 如何选择滚降因子？**  
A: 0.35 是常用值。带宽受限时用更小值，定时误差大时用更大值。

**Q4: Num Taps 如何选择？**  
A: 通常 11 × sps。更多 taps 提供更好性能但增加延迟。

**Q5: 输出端和输入端的参数必须相同吗？**  
A: 是的，Symbol Rate 和 Excess BW 必须完全匹配。

**Q6: 可以用于哪些符号映射方式？**  
A: RRC 适用于 PSK、QAM、ASK 等线性符号映射方式。

**Q7: 如何验证滤波器设计？**  
A: 查看时域和频域响应，检查眼图，测量 ISI。

## 眼图分析

**理想眼图：**
- 眼睛完全张开
- 采样时刻无 ISI
- 清晰的判决区域

**RRC 滤波器的作用：**
- 限制带宽
- 控制符号间干扰
- 形成清晰的眼图

**眼图闭合的原因：**
- 滚降因子不匹配
- 定时误差
- 传播失真
- 噪声

## 典型应用场景

**水声数字链路实验：**
```
[Data] → [FEC] → [Waveform Mapper] → [RRC] → [Acoustic Output]
```

**记录数据回放验证：**
```
[Baseband] → [RRC Output] → [Propagation Model] → [RRC Input] → [Symbol Detector]
```

**数字基带实验链路：**
```
[Symbol Generator] → [RRC] → [Output Node]
[Complex Sample Source] → [RRC] → [Symbol Sync] → [Decoder]
```

**测试和仿真：**
```
[Test Pattern] → [RRC] → [AWGN] → [RRC] → [BER Measurement]
```

## 相关 Block

- [Interpolating FIR Filter](Interpolating_FIR_Filter.md)：用于输出端的符号成形
- [Decimating FIR Filter](Decimating_FIR_Filter.md)：用于输入端的匹配滤波
- **Polyphase Clock Sync**：符号定时恢复
- **Constellation Decoder**：符号解映射

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
