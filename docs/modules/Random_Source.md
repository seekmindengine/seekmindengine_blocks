# Random Source 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Random Source

## 概览

Random Source 模块生成指定范围内的随机整数序列。可以设置最小值、最大值，并可选择是否重复样本。主要用于生成测试数据和随机比特流。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Waveform Generators（波形发生器） |
| Block ID | `analog_random_source_x` |
| 处理模型 | 连续样本流 |
| 典型位置 | Source（数据源） |
| 执行支持 | Python |

## 何时使用

1. **算法链路测试**  
   生成随机序列测试检测、编码或解码流程

2. **加扰器测试**  
   为加扰/解扰算法提供测试数据

3. **随机数据生成**  
   生成随机数据用于各种测试

4. **蒙特卡洛仿真**  
   提供随机输入进行统计分析

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输出 | `默认` | 样本流 | 由数据类型参数决定 | 连续样本流端口 |

> 先核对输出类型与数据含义；离线处理可尽快运行，需要近似实时显示时再配置速率控制。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Output Type** | 枚举 | 选择输出端样本类型 | int | ✗ |
| **Minimum** | 整数 | 设置随机输出或显示范围的下限 | 0 | ✗ |
| **Maximum** | 整数 | 设置随机输出或显示范围的上限 | 2 | ✗ |
| **Num Samples** | 整数 | 设置生成或保留的样本数量 | 1000 | ✗ |
| **Repeat** | 枚举 | 控制有限随机样本表播放完后是否重复 | Yes | ✗ |

## 参数说明

**1. Output Type**
- 输出数据类型
  - int
  - short
  - byte

**2. Minimum**
- 最小值

**3. Maximum**
- 最大值

**4. Num Samples**
- 随机源在重复或重置前使用的样本数量。
**5. Repeat**
- 是否重复
  - **Yes**：True
  - **No**：False

## 工作原理

```
构造时生成有限随机表 → 输出样本 → 重复同一张表（可选）
[Min, Max)      Num Samples
```

Repeat=Yes 反复播放同一组 Num Samples 数据，不会每轮重新抽取随机数。面板没有 Seed 参数，重新构造流程时通常会产生不同数据。需要每个 item 持续生成随机整数时使用 Random Uniform Source。

**随机范围：**
- 输出值 ∈ [Minimum, Maximum)
- Maximum 值不会被包含

## 快速示例

**示例 1：生成随机比特**

```
[Random Source] → [Pack K Bits] → [PSK Mapper] → [Propagation Model] → [PSK Detector]
  (0-2, byte)      (1 bit)
```

配置参数：
- Output Type: Byte
- Minimum: 0
- Maximum: 2  (生成 0 或 1)
- Num Samples: 10000
- Repeat: Yes

**示例 2：生成随机字节**

```
[Random Source] → [File Sink]
  (0-256)          ("random_data.bin")
```

配置参数：
- Output Type: Byte
- Minimum: 0
- Maximum: 256
- Num Samples: 1000000
- Repeat: No

**示例 3：测试数据**

```
[Random Source] → [Your Block] → [BER Calculation]
  (test pattern)
```

配置参数：
- Minimum: 0
- Maximum: 16  (生成 0-15)
- Repeat: Yes

## 与 Noise Source 的区别

| 特性 | Random Source | Noise Source |
|------|--------------|--------------|
| 输出类型 | 整数 | Float/Complex/Short/Int，依配置 |
| 分布 | 均匀分布（离散） | 高斯/均匀（连续） |
| 用途 | 数字数据 | 模拟噪声 |
| 重复性 | 可重复固定序列 | 每次不同 |

## 性能与部署

在目标采样率和数据规模下验证 CPU、内存与端到端延迟。动态参数、向量长度和并行通道增加时应重新测量。

## 故障排查

**Q1: 如何生成 0 和 1？**  
A: 设置 Minimum=0, Maximum=2。

**Q2: 随机序列每次运行都相同吗？**  
A: Repeat=Yes 时，序列在每次循环中相同，但不同运行可能不同。

**Q3: 如何生成更多样本？**  
A: 增大 Num Samples 参数。

**Q4: 可以生成负数吗？**  
A: 可以，使用 Short 或 Int 类型，设置负的 Minimum 值。

## 典型应用

**BER 测试：**
```
[Random Source] → [Waveform Mapper] → [Propagation Model] → [Symbol Detector] → [BER]
```

**加扰测试：**
```
[Random Source] → [Scrambler] → [Descrambler] → [Compare]
```

**数据生成：**
```
[Random Source] → [Frame Encoder] → [Output Node]
```

## 相关 Block

- [Noise Source](Noise_Source.md)：生成连续噪声
- [Random Uniform Source](Random_Uniform_Source.md)：均匀分布随机数
- [GLFSR Source](GLFSR_Source.md)：伪随机序列生成器

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
