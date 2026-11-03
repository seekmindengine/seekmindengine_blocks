# Vector to Streams 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Vector to Streams

## 概览

Vector to Streams 模块是 Streams to Vector 的逆操作。它将一路向量输入拆分为 Num Streams 路输出，每路保留 Vector Length 个连续元素；Vector Length=1 时，每个元素对应一路标量流。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Stream Operators（流操作） |
| Block ID | `blocks_vector_to_streams` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **向量拆分**  
   将 FFT 等向量处理模块的输出拆分为独立通道

2. **多通道分发**  
   将合并的向量数据分发到各独立处理链路

3. **数据解析**  
   从打包的向量数据中提取各分量

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | IO Type × (Vector Length × Num Streams) | 固定一路向量输入 |
| 输出 | `0 .. Num Streams−1` | 样本流 | IO Type × Vector Length | 每轮每路产生一个 item |

> 数据类型、向量长度和标签传播规则属于连接契约。即使流程可以启动，配置不一致仍可能造成错位或语义错误。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **IO Type** | 枚举 | 选择输入输出样本类型，连接两端必须一致 | float | ✗ |
| **Num Streams** | 整数 | 设置并行样本流数量 | 2 | ✗ |
| **Vector Length** | 整数 | 设置每个向量包含的元素数量 | 1 | ✗ |

## 工作原理

```
输入: [[a0, b0, c0], [a1, b1, c1], ...]

输出0: [a0, a1, ...]
输出1: [b0, b1, ...]
输出2: [c0, c1, ...]
```

## 快速示例

```
[FFT] → [Vector to Streams (N=4)] → 输出0: Bin 0
                                     → 输出1: Bin 1
                                     → 输出2: Bin 2
                                     → 输出3: Bin 3
```

## 性能与部署

在目标采样率和数据规模下验证 CPU、内存与端到端延迟。动态参数、向量长度和并行通道增加时应重新测量。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 流程无法连接 | 数据类型、向量长度或端口数量不匹配 | 对照“输入与输出”统一连接契约 |
| 运行结果异常 | 采样率语义或关键参数不一致 | 使用确定性输入，从默认参数逐项验证 |

更多通用排查方法见[故障排查指南](../TROUBLESHOOTING.md)。

## 相关 Block

- [Streams to Vector](Streams_to_Vector.md)：反向操作
- [Stream to Vector](Stream_to_Vector.md)：将标量流转为向量流
- [Vector to Stream](Vector_to_Stream.md)：将向量流拆为标量流

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
