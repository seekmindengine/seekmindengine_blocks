# Throttle 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Throttle

## 概览

Throttle 模块用于控制数据流的传输速率，确保平均采样率不超过指定值。该模块将输入端的数据项复制到输出端，或按照指定的平均速率消耗输入样本，但不会对数字信号本身进行任何修改。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Misc（其他） |
| Block ID | `blocks_throttle2` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **仿真环境中的速率限制**  
   在纯软件仿真的流图中，Throttle 模块可以限制 CPU 使用率，防止处理器负载达到 100%

2. **GUI 应用中的流量控制**  
   在图形界面应用中，当没有其他速率限制模块时使用

3. **开发调试**  
   在开发和测试阶段控制数据流速度，便于观察和分析

## 重要说明

⚠️ **使用限制：**
- Throttle 模块**不应该**用于精确控制采样率
- 在实际硬件应用中（如采集卡、音频卡等），采样率应由与采样时钟绑定的采集或输出设备控制
- 该模块主要用于没有硬件速率限制的仿真场景

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | 由数据类型和向量长度参数决定 | 连续样本流端口 |
| 输出 | `默认` | 样本流 | 由数据类型和向量长度参数决定 | 连续样本流端口；可选 |

> 连接前核对数据类型、向量长度、采样率语义和端口数量；首次运行使用可观察的 Sink 验证结果。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Type** | 枚举 | 选择样本数据类型，必须与相连端口一致 | float | ✗ |
| **Sample Rate** | 浮点数 | 设置目标 item 率，单位为 item/s；向量整体计为一个 item | 32000 | ✓ |
| **Vector Length** | 整数 | 设置每个向量包含的元素数量 | 1 | ✗ |
| **Ignore rx_rate tag** | 枚举 | 控制是否忽略输入流中的 rx_rate 标签 | True | ✗ |
| **Limit** | 枚举 | 设置单次处理批量的限制方式，不是总输出长度 |  | ✗ |
| **Maximum** | 浮点数 | Limit 为时间时表示最大秒数，为 items 时表示每批最大 item 数 | 0.1 | Python ✗ / C++ ✓ |

## 参数说明

**1. Type**
- 数据类型
  - complex
  - float
  - int
  - short
  - byte

**2. Sample Rate**
- 采样率（Hz）

**3. Vector Length**
- 向量长度

**4. Ignore rx_rate tag**
- 忽略 rx_rate 标签
  - True
  - False

**5. Limit**
- 单次处理批量限制；None 仍按 Sample Rate 限速
  - **None**：auto
  - **Max Time (sec)**：time
  - **Max Items**：items

**6. Maximum**
- `Limit=Max Time (sec)` 时换算为每批最多约 `Maximum × Sample Rate` 个 item
- `Limit=Max Items` 时表示每批最大 item 数
- Python 模板在创建 Block 时使用该值，但没有对应 callback；C++ 模板提供 `set_maximum_items_per_chunk` callback

## 工作原理

Throttle 模块通过以下方式控制数据流速率：

1. **时间计算**：根据设置的采样率计算每批数据应该花费的时间
2. **延迟插入**：如果数据处理速度过快，模块会插入适当的延迟
3. **数据传递**：将输入数据原样复制到输出，不改变数据内容

```
输入速率 > 目标速率 → 插入延迟
输入速率 ≤ 目标速率 → 直接传递
```

## 快速示例

**示例 1：基本仿真流图**

```
[Signal Source] → [Throttle] → [QT GUI Time Sink]
                   (samp_rate)
```

在这个例子中：
- Signal Source 生成信号
- Throttle 限制数据流速率为 `samp_rate`
- QT GUI Time Sink 显示波形

**示例 2：多路信号处理**

```
[Noise Source] → [Throttle] → [Low Pass Filter] → [QT GUI Frequency Sink]
                 (32000 sps)
```

配置参数：
- Type: Complex
- Sample Rate: 32000
- Vec Length: 1
- Ignore Tags: True

## 性能与部署

1. **CPU 使用率**  
   适当的 Throttle 设置可以显著降低 CPU 使用率，特别是在仿真环境中

2. **精度限制**  
   Throttle 提供的是粗略的速率控制，不适合需要精确时序的应用

3. **延迟影响**  
   Throttle 会引入额外的处理延迟，在实时系统中需要考虑这一因素

## 故障排查

**Q1: 为什么在使用硬件设备时不需要 Throttle？**  
A: 硬件设备（如采集卡、嵌入式采集节点、音频卡）有自己的采样时钟，会自动控制数据流速率。Throttle 主要用于纯软件仿真。

**Q2: Throttle 会改变信号内容吗？**  
A: 不会。Throttle 只控制数据流速率，不对信号进行任何处理或修改。

**Q3: 如何选择合适的采样率？**  
A: 采样率应该：
- 按当前位置的 item 率设置；向量长度为 V 时，item 率为标量元素率除以 V
- 经过抽取、插值或向量转换后，重新计算这一段的 item 率
- 考虑 CPU 处理能力

**Q4: 可以在一个流图中使用多个 Throttle 吗？**  
A: 可以，但通常不推荐。一般在信号源之后使用一个 Throttle 就足够了。

## 相关 Block

- [File Source](File_Source.md) / [File Sink](File_Sink.md)：按调度和磁盘吞吐读写，不提供指定的实时样本率
- **Audio Source / Audio Sink**：音频设备模块，有硬件速率控制
- **Acquisition Source / Output Sink**：硬件采集与输出设备，有精确的采样时钟

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
