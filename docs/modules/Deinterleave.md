# Deinterleave 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Deinterleave

## 概览

Deinterleave 模块将单一输入流中的交织数据按顺序分配到多个输出端口。例如，输入序列 [a0, b0, a1, b1, a2, b2, ...] 可以分离为两路输出：[a0, a1, a2, ...] 和 [b0, b1, b2, ...]。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Stream Operators（流操作） |
| Block ID | `blocks_deinterleave` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **交织数据分离**  
   将多通道交织数据拆分为独立通道

2. **IQ 分离**  
   从交织的 I/Q 数据流中分离出 I 和 Q 分量

3. **多路解复用**  
   从时分复用信号中提取各路数据

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | 由数据类型和向量长度参数决定 | 连续样本流端口 |
| 输出 | `默认` | 样本流 | 由数据类型和向量长度参数决定 | 连续样本流端口；端口数量由参数决定 |

> 数据类型、向量长度和标签传播规则属于连接契约。即使流程可以启动，配置不一致仍可能造成错位或语义错误。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **IO Type** | 枚举 | 选择输入输出样本类型，连接两端必须一致 | Float | ✗ |
| **Num Streams** | 整数 | 设置并行样本流数量 | 2 | ✗ |
| **Block Size** | 整数 | 设置每个处理块包含的条目数量 | 1 | ✗ |
| **Vector Length** | 整数 | 设置每个向量包含的元素数量 | 1 | ✗ |

## 参数说明

**1. IO Type**
- I/O 数据类型
  - **Complex**：complex
  - **Float**：float
  - **Int**：int
  - **Short**：short
  - **Byte**：byte

**2. Num Streams**
- 流数量

**3. Block Size**
- 每次分配到各输出的连续样本数量；必须为正整数。
**4. Vector Length**
- 向量长度

## 工作原理

```
输入: [a0, b0, a1, b1, a2, b2, ...]
Num Outputs = 2, Block Size = 1

输出0: [a0, a1, a2, ...]
输出1: [b0, b1, b2, ...]
```

## 快速示例

```
[Interleaved Source] → [Deinterleave (2 outputs)] → 输出0: I 分量
                                                    → 输出1: Q 分量
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

- [Streams to Vector](Streams_to_Vector.md)：将多路流合并为向量
- [Interleave](Interleave.md)：按相同路数、类型、向量长度和 Block Size 将多路流交织为一路
- [Float To Complex](Float_To_Complex.md)：将拆分后的 I、Q 两路 Float 流组合为 Complex 流

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
