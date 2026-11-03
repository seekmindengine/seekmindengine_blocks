# Symbol Sync 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Symbol Sync

## 概览

Symbol Sync 模块用于从过采样数字调制信号中恢复正确的符号采样时刻。它支持 complex 和 float 两类输入，提供多种 Timing Error Detector（TED）和插值重采样器选项，是数字接收机中非常关键的同步模块。

定时同步的目标不是改变调制方式，而是在接收信号中找到“应该在哪个采样点判决符号”。如果 Samples per Symbol、TED 类型、环路带宽等参数不匹配，后续星座判决会明显恶化。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Synchronizers（同步器） |
| Block ID | `digital_symbol_sync_xx` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **符号定时恢复**  
   从每符号多采样点的信号中恢复符号采样时刻

2. **接收机同步链路**  
   与匹配滤波、Costas Loop、星座判决组合使用

3. **采样率微调**  
   通过插值器补偿符号时钟偏差

4. **同步状态诊断**  
   通过 error、T_inst、T_avg 输出观察环路行为

5. **调制实验**  
   对比 Gardner、Mueller and Müller 等 TED 的表现

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | 由数据类型参数决定 | 连续样本流端口 |
| 输出 | `默认` | 样本流 | 由数据类型参数决定 | 连续样本流端口 |
| 输出 | `error`（1） | 样本流 | float | 可选，定时误差检测器输出 |
| 输出 | `T_inst`（2） | 样本流 | float | 可选，瞬时时钟周期估计，单位输入样本/符号 |
| 输出 | `T_avg`（3） | 样本流 | float | 可选，平均时钟周期估计，单位输入样本/符号 |

> 收发两端应约定调制和编码方式；每符号采样数按当前处理段的采样率计算，接收环路参数则按输入信号与同步需求设置。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---------|------|------|--------|
| **I/O Type** | 枚举 | Complex 或 Float | Complex |
| **Timing Error Detector** | 枚举 | 定时误差检测算法 | Gardner |
| **TED Slicer Constellation** | raw | 部分 TED 使用的切片星座 | QPSK |
| **Samples per Symbol** | 浮点数 | 输入每符号采样点数 | 2 |
| **Expected TED Gain** | 浮点数 | 预期 TED 增益 | 1.0 |
| **Loop Bandwidth** | 浮点数 | 定时环路带宽 | 0.045 |
| **Damping Factor** | 浮点数 | 阻尼系数 | 1.0 |
| **Maximum Deviation** | 浮点数 | 平均时钟周期相对名义 SPS 的最大绝对偏差，单位输入样本/符号 | 1.5 |
| **Output Samples/Symbol** | 整数 | 输出每符号采样点数 | 1 |
| **Interpolating Resampler** | 枚举 | 插值重采样器类型 | MMSE 8 tap FIR |
| **Filterbank Arms** | 整数 | PFB 支路数 | 128 |
| **PFB MF Taps** | 向量 | PFB 匹配滤波 taps | [] |

## 参数说明

**1. I/O Type（输入输出类型）**
- Complex：用于 IQ 调制信号，如 PSK/QAM
- Float：用于实数基带或鉴频后信号

**2. Timing Error Detector（TED）**
- Gardner：常用于每符号约 2 点的线性调制信号
- Mueller and Müller：常用于判决辅助定时恢复
- Early-Late、Zero Crossing 等适用于不同信号模型
- 具体选择应结合调制方式和采样条件验证

**3. Samples per Symbol（输入 SPS）**
- 必须大于 0
- 应等于输入信号实际每符号采样点数
- 错误 SPS 会让环路从一开始就处于错误模型

**4. Loop Bandwidth（环路带宽）**
- 值大：锁定快，但更容易抖动
- 值小：输出更平稳，但锁定慢
- 从默认值附近调整，不建议盲目大幅修改

**5. Damping Factor（阻尼系数）**
- 影响环路动态响应
- 默认 1.0 适合多数起步实验

**6. Output Samples/Symbol（输出 SPS）**
- 1 表示每个符号输出一个采样点，常用于判决
- 大于 1 可保留过采样输出，用于后续处理

**7. Interpolating Resampler（插值器）**
- MMSE 8 tap FIR：默认、轻量
- PFB 方式可提供更多配置，但参数更多

## 端口说明

**输入：**
- 主输入 stream：complex 或 float

**输出：**
- 主输出 stream：同步后的 complex 或 float
- optional `error`：定时误差信号
- optional `T_inst`：瞬时符号周期估计
- optional `T_avg`：平均符号周期估计

## 工作原理

```
输入信号 → TED 计算定时误差 → 环路滤波 → 插值重采样 → 同步输出
```

模块利用相邻采样点或判决结果估计“采样时刻偏早还是偏晚”，再通过插值器调整输出采样位置。

## 快速示例

**示例 1：QPSK 接收链路**

```
[RRC Filter] → [Symbol Sync] → [Costas Loop] → [Constellation Decoder]
```

配置参数：
- I/O Type: Complex
- TED: Gardner
- Samples per Symbol: 与输入信号匹配
- Output Samples/Symbol: 1

**示例 2：观察定时误差**

```
[Signal] → [Symbol Sync] ┬→ [Decoder]
                         └→ [QT GUI Time Sink: error]
```

可选输出按端口序号连续连接。error 趋稳可辅助诊断，还需结合时钟周期估计、星座与已知数据校验判断同步是否正确。

**示例 3：PFB 匹配滤波模式**

```
[Signal] → [Symbol Sync]
            Resampler=PFB MF
            PFB MF Taps=...
```

仅在明确需要 PFB 匹配滤波时配置 taps。

## 调试建议

1. 先确认采样率和符号率，计算正确 SPS
2. 从默认 Gardner + MMSE 8 tap 开始
3. 用 QT GUI Constellation Sink 观察同步前后星座
4. 输出 error/T_avg 观察是否稳定
5. 若星座周期性扩散，检查 SPS 和 Loop Bandwidth
6. 若锁定慢，可小幅增大 Loop Bandwidth

## 性能与部署

在目标采样率和数据规模下验证 CPU、内存与端到端延迟。动态参数、向量长度和并行通道增加时应重新测量。

## 故障排查

**Q1: Symbol Sync 会改变采样率吗？**  
A: 会。输出速率由输入 SPS 和 Output Samples/Symbol 决定。

**Q2: TED 应该怎么选？**  
A: 没有单一通用答案。PSK/QAM 常从 Gardner 开始，根据调制方式和采样条件调整。

**Q3: 为什么输出星座还是旋转？**  
A: Symbol Sync 解决定时问题，载波相位/频偏需要 Costas Loop 等模块处理。

**Q4: Samples per Symbol 可以随便填吗？**  
A: 不可以。它必须反映输入信号实际每符号采样点数。

**Q5: PFB MF Taps 为空可以吗？**  
A: 默认 MMSE 模式下不需要；只有选择 PFB MF 时才需要认真配置。

## 典型应用场景

**PSK 接收机：**

```
[Filtered IQ] → [Symbol Sync] → [Costas Loop] → [Decoder]
```

**GMSK/FSK 实数同步：**

```
[Quadrature Demod] → [Symbol Sync ff] → [Binary Slicer]
```

## 相关 Block

- [Costas Loop](Costas_Loop.md)：载波相位恢复
- [Root Raised Cosine Filter](Root_Raised_Cosine_Filter.md)：匹配滤波
- [PSK Demod](PSK_Demod.md)：层级解调器
- [QT GUI Constellation Sink](QT_GUI_Constellation_Sink.md)：观察同步效果

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
